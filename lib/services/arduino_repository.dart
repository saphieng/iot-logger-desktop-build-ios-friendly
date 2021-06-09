import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:iot_logger/models/HeartBeatMessage.dart';
import 'package:iot_logger/models/Messages.dart';
import 'package:iot_logger/services/windows_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:connectivity/connectivity.dart';
import 'package:location_permissions/location_permissions.dart';

class ArduinoRepository {
  var directory;
  String currentFile = '';
  String wifiIP, wifiName;

  List<String> fileNames = [];
  List<String> indexedFile = [];

  int fileSize = 0;
  int payloadSize = 0;
  int fileSizeCount = 0;
  int sequenceNumber = 0;
  int receivedSensorType = -1;
  int currentPayloadByte = 0;
  int missedBytes = 0;
  int messageCounter = 0;
  int fileIndexCount = 0;
  final int messageDataIndex = 5; //Number of bytes before the data part of a message
  final int sensorType = 0; //App is sensor 0

  Uint8List messageData = Uint8List(256);
  Uint8List messageBuffer = Uint8List(0);

  MessageState currentState = MessageState.START;
  MessageType messageId = MessageType.CONNECT;

  RestartableTimer countdownTimer;
  bool arduinoisConnected = true;
  RawDatagramSocket socket;
  Timer heartBeatTimer;

  BytesBuilder messageFile;
  BytesBuilder fileLine = new BytesBuilder();

  StreamController<MessageFile> fileController;
  Stream<MessageFile> fileStream;
  StreamController<HeartBeatMessage> isConnectedController;
  Stream<HeartBeatMessage> isConnectedStream;
  Stream<List<String>> fileNamesStream;
  StreamController<List<String>> fileNamesController;
  StreamSubscription networkSubscription;
  StreamController<String> settingStreamController;
  Stream<String> settingsStream;
  StreamController<String> currentMeasurementsStreamController;
  Stream<String> currentMeasurementsStream;

  ArduinoRepository() {
    initialiseWifiConnection();
    setLocalDirectory();
    fileController = StreamController<MessageFile>.broadcast();
    fileStream = fileController.stream;
    isConnectedController = StreamController<HeartBeatMessage>.broadcast();
    isConnectedStream = isConnectedController.stream;
    fileNamesController = StreamController<List<String>>.broadcast();
    fileNamesStream = fileNamesController.stream;
    settingStreamController = StreamController<String>.broadcast();
    settingsStream = settingStreamController.stream;
    currentMeasurementsStreamController = StreamController<String>.broadcast();
    currentMeasurementsStream = currentMeasurementsStreamController.stream;
  }

  initialiseWifiConnection() async {
    print("Initialising Wifi Connection...");

    if (Platform.isIOS) {
      // iOS needs an initial connection
      try {
        //var test = await WifiInfo().requestLocationServiceAuthorization();
        var test1 = await WifiInfo().getLocationServiceAuthorization();
        wifiName = await WifiInfo().getWifiName();
        wifiIP = await WifiInfo().getWifiIP();
        // Wifi Connected
        if (wifiIP != null && wifiName != null || test1 != null) {
          print('Wifi Connected: $wifiName $wifiIP');
          initialiseArduinoConnection(wifiIP);
        } else {
          // No Wifi Found
          print('No Wifi Detected');
        }
      } catch (e) {
        print("No Connections Found");
        print(e.toString());
      }
    }



    if (Platform.isWindows) {
      wifiIP = null;
      // Get Wifi Ip
      List<NetworkInterface> addresses = await NetworkInterface.list();

      //print("Network Interfaces:");
      for (int i = 0; i < addresses.length; i++) {
        print('${addresses[i].name}');
        if (addresses[i].name.contains("Wi")) {
          wifiIP = addresses[i].addresses[0].address;
        }
      }

      if (wifiIP != null) {
        // If Wifi is connected
        print('Wifi Connected: $wifiIP');
        initialiseArduinoConnection(wifiIP);
      } else {
        // No Wifi Found
        print('No Wifi Detected');
      }
    }

    if (Platform.isAndroid ) {
      WiFiForIoTPlugin.forceWifiUsage(true);
      // Listen and adjust to changes in the network
      networkSubscription = new Connectivity().onConnectivityChanged.listen(
        (status) async {
          print("Connection Change Detected");
          try {
            wifiName = await WifiInfo().getWifiName();
            wifiIP = await WifiInfo().getWifiIP();

            // If Wifi is connected
            if (wifiIP != null && wifiName != null) {
              print('Wifi Connected: $wifiName @ $wifiIP');
              initialiseArduinoConnection(wifiIP);
            } else {
              // No Wifi Found
              print('No Wifi Detected');
            }
          } catch (e) {
            //messageSubscription.cancel();
            print("No Connections Found");
            print(e.toString());
          }
        },
      );
    }
  }

  initialiseArduinoConnection(String wifiIP) async {
    print("Initialising Arduino Connection...");

    // Create UDP Socket to Arduino
    socket = await RawDatagramSocket.bind(InternetAddress(wifiIP), 2305,
        reuseAddress: true);

    print('Creating UDP Server @ ${socket.address.address}:${socket.port}');

    // Start Heart Beat timer
    print("sending heart beat's");
    heartBeatTimer = new Timer.periodic(Duration(seconds: 1), (Timer t) {
      messageBuffer = Uint8List.fromList(
          [0xFE, 1, messageCounter, 0, 0, 1]); // Heart Beat Message
      sendMessageBuffer(messageBuffer);
    });

    //Listen for messages
    socket.listen(
      (data) {
        Datagram d = socket.receive();
        if (d == null) return;
        readMessage(d.data);
      },
      onError: (err) {
        print('$err');
      },
      cancelOnError: false,
      onDone: () {
        print("Stream restarting");
      },
    );

    // Start connection timer
    print("starting connection timer");
    countdownTimer = new RestartableTimer(Duration(seconds: 3), () {
      arduinoisConnected = false;
      isConnectedController.add(HeartBeatMessage(false, receivedSensorType));
      print("Arduino timed out");
    });
  }

  void stopHeartBeat() {
    print("arduino disconnected");
    arduinoisConnected = false;
  }

  void readMessage(Uint8List data) {
    for (int i = 0; i < data.length; i++) {
      msgParseByte(data[i]);
    }
  }

  void closeConnections() {
    try {
      socket.close(); // Closing the stream calls initialiseWifiConnection();
      initialiseWifiConnection();
      heartBeatTimer.cancel();
      countdownTimer.cancel();

      if (!Platform.isWindows) {
        networkSubscription.cancel();
      }
    } catch (e) {
      print(e);
    }
  }

  void msgParseByte(int messageByte) {
    switch (currentState) {
      case MessageState.START:
        if (messageByte == 0xFE) {
          currentState = MessageState.PAYLOAD;
        } else {
          print("Waiting byte recieved: + $messageByte");
        }
        break;
      case MessageState.PAYLOAD:
        payloadSize = messageByte;
        currentState = MessageState.SEQUENCE;
        break;
      case MessageState.SEQUENCE:
        if ((sequenceNumber) != messageByte) {
          print("Bad sequence number: $sequenceNumber vs $messageByte");

          //26 vs 33
          if (sequenceNumber < messageByte) {
            missedBytes = missedBytes + ((messageByte - sequenceNumber) * 255);
          } else {
            //242 vs 4
            missedBytes =
                missedBytes + (((255 - sequenceNumber) + messageByte) * 255);
          }
        }
        sequenceNumber = messageByte + 1;
        if (sequenceNumber == 256) {
          sequenceNumber = 0;
        }
        currentState = MessageState.SENSOR_TYPE;
        break;
      case MessageState.SENSOR_TYPE:
        receivedSensorType = messageByte;
        currentState = MessageState.MESSAGE_ID;
        break;
      case MessageState.MESSAGE_ID:
        messageId = messageMap[messageByte];
        currentState = MessageState.DATA;
        break;
      case MessageState.DATA:
        parsePayloadByte(messageByte);
        break;
      default:
        print("Bad message state");
        break;
    }
  }

  void parsePayloadByte(int payloadByte) {
    messageData[currentPayloadByte] = payloadByte;
    currentPayloadByte++;
    if (currentPayloadByte >= payloadSize) {
      // All data bytes read so parse it
      parsePayload();
      currentPayloadByte = 0;
      currentState = MessageState.START;
    }
  }

  // Incoming Messages
  parsePayload() {
    //Do something with the data payload
    messageData[currentPayloadByte] = 0;
    switch (messageId) {
      case MessageType.HEART_BEAT:
        // print("heart beat received");
        arduinoisConnected = true;
        isConnectedController.add(HeartBeatMessage(true, receivedSensorType));
        countdownTimer.reset();
        break;
      case MessageType.CONNECT:
        print('CONNECT ' + String.fromCharCodes(messageData));
        break;
      case MessageType.SEND_LOG_FILE_SIZE:
        ByteData logFileSize =
            ByteData.sublistView(messageData, 0, payloadSize);
        fileSize = logFileSize.getInt32(0, Endian.little);
        // print('Log File Size Received = ' + fileSize.toString());
        break;
      case MessageType.SEND_LOG_FILE_NAME:
        print('Log File Name Received: ' +
            String.fromCharCodes(
                messageData.sublist(0, payloadSize))); //messageData

        fileNames
            .add(String.fromCharCodes(messageData.sublist(0, payloadSize)));

        fileNamesController.add(fileNames);
        break;
      case MessageType.SEND_LOG_FILE_CHUNK:
        fileSizeCount += messageData.sublist(0, payloadSize).lengthInBytes;

        addChunkToFile(messageData.sublist(0, payloadSize));

        double fileSizePercantage = (fileSizeCount / (fileSize));

        print("Current Log File Size = " +
            fileSizeCount.toString() +
            " estimatedtotalSize = " +
            (fileSize).toString());

        fileController.add(MessageFile(fileSizePercantage, indexedFile));

        break;
      case MessageType.SEND_SD_CARD_INFO:
        ByteData sdCardInfo = ByteData.sublistView(messageData, 0, payloadSize);
        print('Card Used Space: ' +
            sdCardInfo.getInt16(0, Endian.little).toString() +
            ' Card Remaining Space: ' +
            sdCardInfo.getInt16(2, Endian.little).toString());
        settingStreamController.add(
            "${sdCardInfo.getInt16(0, Endian.little).toString()},${sdCardInfo.getInt16(2, Endian.little).toString()}");
        break;
      case MessageType.SEND_LOGGING_PERIOD:
        ByteData loggingPeriod =
            ByteData.sublistView(messageData, 0, payloadSize);
        print('Logging Period Received: ' +
            loggingPeriod.getInt32(0, Endian.little).toString());
        settingStreamController
            .add(loggingPeriod.getInt32(0, Endian.little).toString());
        break;
      case MessageType.SEND_RTC_TIME:
        ByteData rtcTime = ByteData.sublistView(messageData, 0, payloadSize);
        print('Received RTC Time = ' +
            rtcTime.getInt32(0, Endian.little).toString());
        DateTime time = new DateTime.fromMillisecondsSinceEpoch(
            (rtcTime.getInt32(0, Endian.little) * 1000),
            isUtc: false);

        String minutes = time.minute.toString();
        if (minutes.length != 2) {
          minutes = '0' + minutes;
        }
        settingStreamController.add(time.hour.toString() +
            ":" +
            minutes.toString() +
            " " +
            time.day.toString() +
            "/" +
            time.month.toString() +
            "/" +
            time.year.toString());
        break;
      case MessageType.SEND_CURRENT_MEASUREMENTS:
        currentMeasurementsStreamController
            .add(String.fromCharCodes(messageData.sublist(0, payloadSize)));
        break;
      case MessageType.SEND_BATTERY_INFO:
        ByteData batteryInfo =
            ByteData.sublistView(messageData, 0, payloadSize);
        print('Battery Voltage: ' +
            batteryInfo.getFloat32(0, Endian.little).toString() +
            ' Battery ADC Reading: ' +
            batteryInfo.getInt32(4, Endian.little).toString());
        settingStreamController.add(
            "${batteryInfo.getFloat32(0, Endian.little).toStringAsFixed(2)},${batteryInfo.getInt32(4, Endian.little).toString()}");
        break;
      case MessageType.SEND_WIFI_DETAILS:
        String value =
            String.fromCharCodes(messageData.sublist(0, payloadSize));

        List<String> result = value.split(",");
        wifiName = result[0];

        settingStreamController.add(value); //messageData

        break;
      case MessageType.ERROR_MSG:
        print('Error Message Received: ' +
            String.fromCharCodes(
                messageData.sublist(0, payloadSize))); //messageData
        break;
      default:
        print(
            'Default Message Type (means this message type has not been mapped');
    }
  }

  void addChunkToFile(Uint8List chunk) {
    String line = "";
    List<String> splitLine = [];

    for (int i = 0; i < chunk.length; i++) {
      fileLine.add([chunk[i]]);
      if (chunk[i] == 10) {
        line = String.fromCharCodes(fileLine.takeBytes());
        splitLine = line.split(",");

        //At end of line, check for six strings and the starting if there arent six strings remove
        if (splitLine.length == 6 &&
            line.length < 62 &&
            (splitLine[0].length == 19 || splitLine[0].length == 9)) {
          indexedFile.add(line);
        } else {
          //Checks if the line is apart of a DEV-LOG.CSV file
          if (splitLine.length == 1) {
            indexedFile.add(line);
          } else {
            print("BAD LINE FOUND: $line ${splitLine.length}");
          }
        }
      }
    }
  }

  Future<void> writeListToFile(List<String> list) async {
    if (wifiName == null) {
      getWifiDetails();
      await settingStreamController.stream.first;
    }

    var downloadPath = directory.path + "\\" + wifiName + "_" + currentFile;

    // Delete the file if it exists
    if (await File(downloadPath).exists()) {
      await File(downloadPath).delete();
    }

    // Write log file chunk to file, if there is no file this will create one
    print('Writing download string to file at: $downloadPath');
    for (int i = 0; i < list.length; i++) {
      File(downloadPath).writeAsStringSync(list[i], mode: FileMode.append);
    }
  }

  // Outgoing Messages
  getLoggingPeriod() {
    int payloadSize = 1;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.GET_LOGGING_PERIOD];
    messageBuffer[5] = 1; // Payload
    sendMessageBuffer(messageBuffer);
    print('SENT LOGGING PERIOD REQUEST');
  }

  getBatteryInfo() {
    int payloadSize = 1;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.GET_BATTERY_INFO];
    messageBuffer[5] = 1; // Payload
    sendMessageBuffer(messageBuffer);
    print('SENT BATTERY INFO REQUEST');
  }

  getSDCardInfo() {
    int payloadSize = 1;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.GET_SD_CARD_INFO];
    messageBuffer[5] = 1; // Payload
    sendMessageBuffer(messageBuffer);
    print('SENT SD CARD INFO REQUEST');
  }

  getRTCTime() {
    int payloadSize = 1;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.GET_RTC_TIME];
    messageBuffer[5] = 1; // Payload
    sendMessageBuffer(messageBuffer);
    print('SENT RTC TIME REQUEST');
  }

  setRTCTime() {
    int time = (new DateTime.now().millisecondsSinceEpoch / 1000).round();
    int payloadSize = 4;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.SET_RTC_TIME];
    messageBuffer
      ..buffer.asByteData().setInt32(5, time, Endian.little); // Payload
    sendMessageBuffer(messageBuffer);
  }

  setLoggingPeriod(int loggingPeriod) {
    int payloadSize = 4;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.SET_LOGGING_PERIOD];
    messageBuffer
      ..buffer
          .asByteData()
          .setInt32(5, loggingPeriod, Endian.little); // Payload
    sendMessageBuffer(messageBuffer);
  }

  getLogsList() {
    fileNames = [];
    int payloadSize = 1;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.GET_LOGS_LIST];
    messageBuffer[5] = 1; // Payload
    sendMessageBuffer(messageBuffer);
    print('SENT GET LOG LIST REQUEST');
  }

  getWifiDetails() {
    int payloadSize = 1;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.GET_WIFI_DETAILS];
    messageBuffer[5] = 1; // Payload
    sendMessageBuffer(messageBuffer);
    print('SENT GET WIFI DETAILS REQUEST');
  }

  getLogFile(String fileName) {
    //fileStream = fileController.stream;
    fileSizeCount = 0;
    missedBytes = 0;
    fileSize = 0;
    messageFile = new BytesBuilder();
    fileLine = new BytesBuilder();
    indexedFile = [];
    fileIndexCount = 0;
    currentFile = fileName;

    //clear the file if it is already present
    if (File('${directory.path}/${wifiName}_$currentFile').existsSync()) {
      print(
          "Deleted Existing ${directory.path}/${wifiName}_$currentFile' file");
      File('${directory.path}/${wifiName}_$currentFile').delete();
    }

    List<int> bytes = fileName.codeUnits;
    int payloadSize = bytes.length;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.GET_LOG_FILE];
    for (int i = 0; i < payloadSize; i++) {
      messageBuffer[i + messageDataIndex] =
          bytes[i]; // insert fileName String as payload
    }

    sendMessageBuffer(messageBuffer);
    print('SENT LOG FILE REQUEST: $fileName');
  }

  getLogFileSize(String fileName) {
    List<int> bytes = fileName.codeUnits;
    int payloadSize = bytes.length;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.GET_LOG_FILE_SIZE];
    for (int i = 0; i < payloadSize; i++) {
      messageBuffer[i + messageDataIndex] =
          bytes[i]; // insert fileName as payload
    }

    sendMessageBuffer(messageBuffer);
    print('SENT LOG FILE SIZE REQUEST: $fileName');
  }

  getCurrentMeasurements(int decimalPlaces) {
    int payloadSize = 4;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.GET_CURRENT_MEASURMENTS];
    messageBuffer
      ..buffer
          .asByteData()
          .setInt32(5, decimalPlaces, Endian.little); // Payload
    sendMessageBuffer(messageBuffer);
    // print('SENT CURRENT MEASUREMENT REQUEST');
  }

  setWifiSSID(String ssid) {
    List<int> bytes = ssid.codeUnits;
    int payloadSize = bytes.length;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.SET_WIFI_SSID];

    for (int i = 0; i < payloadSize; i++) {
      messageBuffer[i + messageDataIndex] =
          bytes[i]; // insert fileName as payload
    }

    sendMessageBuffer(messageBuffer);
    print('SENT SET WIFI SSID REQUEST');
  }

  setWifiPassword(String password) {
    List<int> bytes = password.codeUnits;
    int payloadSize = bytes.length;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.SET_WIFI_PASSWORD];
    for (int i = 0; i < payloadSize; i++) {
      messageBuffer[i + messageDataIndex] = bytes[i]; // insert ssid as payload
    }

    sendMessageBuffer(messageBuffer);
    print('SENT SET WIFI PASSWORD REQUEST');
  }

  deleteLogFile(String fileName) {
    List<int> bytes = fileName.codeUnits;
    int payloadSize = bytes.length;
    messageBuffer = new Uint8List(payloadSize + messageDataIndex);
    messageBuffer[0] = 0xFE;
    messageBuffer[1] = payloadSize;
    messageBuffer[2] = messageCounter;
    messageBuffer[3] = sensorType;
    messageBuffer[4] = messageIndexMap[MessageType.DELETE_LOG_FILE];
    for (int i = 0; i < payloadSize; i++) {
      messageBuffer[i + messageDataIndex] =
          bytes[i]; // insert fileName as payload
    }

    sendMessageBuffer(messageBuffer);
    new Future.delayed(const Duration(seconds: 1), () => getLogsList());
    print('SENT DELETE FILE REQUEST');
  }

  sendMessageBuffer(Uint8List messageBuffer) {
    try {
      socket.send(messageBuffer, InternetAddress("10.0.0.1"), 2506);
      messageCounter++;
    } catch (e) {
      print(e);
      initialiseArduinoConnection(wifiIP);
    }
  }

  Future<void> setLocalDirectory() async {
    directory = Platform.isWindows
        ? await getDownloadsDirectory()
        : await getApplicationDocumentsDirectory();
    print(directory);
  }
}

Map messageIndexMap = {
  MessageType.HEART_BEAT: 0,
  MessageType.CONNECT: 1,
  MessageType.GET_CURRENT_MEASURMENTS: 2,
  MessageType.GET_LOG_FILE: 3,
  MessageType.SEND_LOG_FILE_SIZE: 4,
  MessageType.SEND_LOG_FILE_CHUNK: 5,
  MessageType.GET_LOGGING_PERIOD: 6,
  MessageType.SET_LOGGING_PERIOD: 7,
  MessageType.SEND_SD_CARD_INFO: 8,
  MessageType.GET_LOGS_LIST: 9,
  MessageType.SEND_LOG_FILE_NAME: 10,
  MessageType.SEND_LOGGING_PERIOD: 11,
  MessageType.GET_RTC_TIME: 12,
  MessageType.SET_RTC_TIME: 13,
  MessageType.SEND_RTC_TIME: 14,
  MessageType.SEND_CURRENT_MEASUREMENTS: 15,
  MessageType.DELETE_LOG_FILE: 16,
  MessageType.GET_SD_CARD_INFO: 17,
  MessageType.GET_BATTERY_INFO: 18,
  MessageType.SEND_BATTERY_INFO: 19,
  MessageType.GET_LOG_FILE_SIZE: 20,
  MessageType.SET_WIFI_SSID: 21,
  MessageType.SET_WIFI_PASSWORD: 22,
  MessageType.GET_WIFI_DETAILS: 23,
  MessageType.SEND_WIFI_DETAILS: 24,
  MessageType.ERROR_MSG: 200
};

//Defines the states of the state machine to parse a full message
enum MessageState {
  WAITING,
  START,
  PAYLOAD,
  SEQUENCE,
  SENSOR_TYPE,
  MESSAGE_ID,
  DATA
}
