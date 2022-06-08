
import 'dart:convert';

import 'package:http/http.dart';

class ErrorHandler{
  Response? response;
  bool hasError = false;
  String? errorMessage;

  ErrorHandler({response}){
    this.response = response;
    validateResponse();
  }

  void validateResponse(){
    if(response == null){
      hasError = true;
      errorMessage = "network down";
      return;
    }
    if(["200", "201", "202", "203", "204"].contains(response?.statusCode.toString())){
      return;
    }
    else{
      Map<String, dynamic> decodedResponse = {};
      try{
        decodedResponse = Map<String, dynamic>.from(json.decode(response!.body));
      }
      catch (e){
        hasError = true;
        errorMessage = "Network Error. Please try again later";
        return;
      }
      if(decodedResponse["results"] != null){
        if(decodedResponse["results"] is List){
          decodedResponse = decodedResponse["results"][0];
        }else if (decodedResponse["results"] is Map){
          decodedResponse = decodedResponse["results"] ;
        }
      }
      hasError = true;
      if(decodedResponse["detail"] != null){
        errorMessage = decodedResponse["detail"].toString();
        return;
      }
      try{
        if(decodedResponse["results"] != null) decodedResponse = decodedResponse["results"];
      }catch(e){
        errorMessage = decodedResponse["results"].toString();
        return;
      }
      if(decodedResponse["error"] != null){
        try{
          errorMessage =  decodedResponse["error"]["responseMessage"];
        }catch(e){
          errorMessage = decodedResponse["error"];
        }
      }
      else{
        if(decodedResponse["data"] != null){
          errorMessage = decodedResponse["data"];
        }
        else{
          errorMessage = "An error occurred";
        }

      }
    }
  }
}