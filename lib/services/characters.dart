import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:marvel_challenge/services/base_service.dart';

class CharactersService {
  static dynamic charactersList(int offset) async {
    var client = http.Client();
    try {
      var response = await client.get(
        Uri.parse(BaseService.baseUrl +
            'characters?limit=30&offset=$offset&' +
            BaseService.baseAuth),
        headers: {
          'Accept': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return null;
    } finally {
      client.close();
    }
  }

  static dynamic getCharacterById(int uniqueId) async {
    var client = http.Client();
    try {
      var response = await client.get(
        Uri.parse(BaseService.baseUrl +
            'characters/$uniqueId?' +
            BaseService.baseAuth),
        headers: {
          'Accept': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return null;
    } finally {
      client.close();
    }
  }

  static dynamic characterComics(int uniqueId) async {
    var client = http.Client();
    try {
      var response = await client.get(
        Uri.parse(BaseService.baseUrl +
            'characters/$uniqueId/comics?formatType=comic&' +
            BaseService.baseAuth),
        headers: {
          'Accept': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return null;
    } finally {
      client.close();
    }
  }
}
