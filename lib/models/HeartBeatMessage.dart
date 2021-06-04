class HeartBeatMessage {
  bool isConnected;
  int sensorID;

  HeartBeatMessage(bool isConnected, int sensorID) {
    this.isConnected = isConnected;
    this.sensorID = sensorID;
  }
}

Map sensorMap = {
  -1: "Sensor",
  0: "App",
  1: "TURBIDITY",
  2: "PH",
};
