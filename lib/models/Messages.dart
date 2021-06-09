import 'dart:core';

enum MessageType {
  HEART_BEAT,
  CONNECT,
  GET_CURRENT_MEASURMENTS,
  GET_LOG_FILE,
  SEND_LOG_FILE_SIZE,
  SEND_LOG_FILE_CHUNK,
  GET_LOGGING_PERIOD,
  SET_LOGGING_PERIOD,
  SEND_SD_CARD_INFO,
  GET_LOGS_LIST,
  SEND_LOG_FILE_NAME,
  SEND_LOGGING_PERIOD,
  GET_RTC_TIME,
  SET_RTC_TIME,
  SEND_RTC_TIME,
  SEND_CURRENT_MEASUREMENTS,
  DELETE_LOG_FILE,
  GET_SD_CARD_INFO,
  GET_BATTERY_INFO,
  SEND_BATTERY_INFO,
  GET_LOG_FILE_SIZE,
  ERROR_MSG,
  SET_WIFI_SSID,
  SET_WIFI_PASSWORD,
  GET_WIFI_DETAILS,
  SEND_WIFI_DETAILS
}

class MessageFile {
  double percentage;
  List<String> list;
  MessageFile(double percentage, List<String> list) {
    this.percentage = percentage;
    this.list = list;
  }
}

Map messageMap = {
  0: MessageType.HEART_BEAT,
  1: MessageType.CONNECT,
  2: MessageType.GET_CURRENT_MEASURMENTS,
  3: MessageType.GET_LOG_FILE,
  4: MessageType.SEND_LOG_FILE_SIZE,
  5: MessageType.SEND_LOG_FILE_CHUNK,
  6: MessageType.GET_LOGGING_PERIOD,
  7: MessageType.SET_LOGGING_PERIOD,
  8: MessageType.SEND_SD_CARD_INFO,
  9: MessageType.GET_LOGS_LIST,
  10: MessageType.SEND_LOG_FILE_NAME,
  11: MessageType.SEND_LOGGING_PERIOD,
  12: MessageType.GET_RTC_TIME,
  13: MessageType.SET_RTC_TIME,
  14: MessageType.SEND_RTC_TIME,
  15: MessageType.SEND_CURRENT_MEASUREMENTS,
  16: MessageType.DELETE_LOG_FILE,
  17: MessageType.GET_SD_CARD_INFO,
  18: MessageType.GET_BATTERY_INFO,
  19: MessageType.SEND_BATTERY_INFO,
  20: MessageType.GET_LOG_FILE_SIZE,
  21: MessageType.SET_WIFI_SSID,
  22: MessageType.SET_WIFI_PASSWORD,
  23: MessageType.GET_WIFI_DETAILS,
  24: MessageType.SEND_WIFI_DETAILS,
  200: MessageType.ERROR_MSG
};
