import 'package:dio/dio.dart';

const BASEURL = "http://localhost:8888";
const FIRSTTOKEN = "bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjI2NTM4Mjc4NDksImlhdCI6MTY1MzgyNzg0OSwidXNlcklkIjoxfQ.705LUN9OEOPXaX4N8kFG272zF9eVUT0WxHU6Z8ZkD0s";
const SECONDTOKEN = "bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjI2NTM4MjcxOTIsImlhdCI6MTY1MzgyNzE5MiwidXNlcklkIjoyfQ.nBHs8oQ5tVOTHk7py8__Tz8p5Mx1eidKOjWBP4wbHaI";
final OPTIONS = BaseOptions(baseUrl: BASEURL, followRedirects: true, headers: {
  "Authorization": FIRSTTOKEN
});
final dio = Dio(OPTIONS);

Future<String> login(String username, password) async {
  final res = await dio
      .put("/users", data: {"username": username, "password": password});
  res.data as Map;
  return res.data["token"];
}

class Tenant {
  late String name, desc;
  late List<String> admins;

  Tenant.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    desc = json["desc"];
    admins = List<String>.from(json["admins"]);
  }
}

Future<List<Tenant>> getTenant(String? nameLike) async {
  late Response resp;
  if (nameLike != null) {
    resp = await dio.get("/tenants/$nameLike");
  } else {
    resp = await dio.get("/users/tenant");
  }

  resp.data as Map;
  List<Tenant> res = [];
  if (resp.data["tenant_list"] == null) {
    return res;
  }
  for (var item in resp.data["tenant_list"]) {
    res.add(Tenant.fromJson(item));
  }
  return res;
}

class Config {
  late String path, tenant;
  late int cap, rate;
  late double fail_upper_rate;

  Config.fromJson(Map<String, dynamic> json) {
    path = json["path"];
    tenant = json["tenant"];
    cap = json["cap"];
    rate = json["rate"];
    fail_upper_rate = json["fail_upper_rate"];
  }
}

Future<List<Config>> getConfigs(String tenant, pathStartWith) async {
  List<Config> res = [];
  final resp = await dio
      .get("/configs/$tenant", queryParameters: {"start_with": pathStartWith});

  if (resp.data["config_map"] == null) {
    return res;
  }
  Map<String, dynamic> tmp = resp.data["config_map"];

  tmp.forEach((key, value) {
    res.add(Config.fromJson({
      "path": key,
      "tenant": tenant,
      "cap": value["cap"],
      "rate": value["rate"],
      "fail_upper_rate": value["fail_upper_rate"],
    }));
  });

  return res;
}

class Apply {
  late String tenant, create_at, applier;
  late List<String> admins;

  Apply.fromJson(Map<String, dynamic> json) {
    tenant = json["tenant"];
    create_at = json["create_at"];
    applier = json["applier"];
    if (json["admins"] == null) {
      admins = [];
    } else {
      admins = List<String>.from(json["admins"]);
    }
  }
}

Future<List<Apply>> getMyApply() async {
  List<Apply> res = [];
  final resp = await dio.get("/users/apply");
  if (resp.data["apply_list"] == null) {
    return res;
  }
  for (var item in resp.data["apply_list"]) {
    res.add(Apply.fromJson({
      'tenant': item["tenant"],
      'create_at': item["create_at"],
      "applier": item["applier"],
      "admins": item["admins"],
    }));
  }
  return res;
}

Future<List<Apply>> getOtherApply() async {
  List<Apply> res = [];
  final resp = await dio.get("/users/other_apply");
  if (resp.data["apply_list"] == null) {
    return res;
  }
  for (var item in resp.data["apply_list"]) {
    res.add(Apply.fromJson({
      'tenant': item["tenant"],
      'create_at': item["create_at"],
      "applier": item["applier"],
      "admins": item["admins"],
    }));
  }

  return res;
}

Future<void> createTenant(String name, desc) async {
  final resp = await dio.post("/tenants/$name", data: {"desc": desc});
}

Future<void> createConfig(String tenant, path, cap, rate, failUpperRate) async {
  final resp = await dio.post("/configs/$tenant", data: {"cap": int.parse(cap), "rate": int.parse(rate), "fail_upper_rate": double.parse(failUpperRate), "key": path});
}

Future<void> updateConfig(String tenant, path, cap, rate, failUpperRate) async {
  final resp = await dio.put("/configs/$tenant", data: {"cap": int.parse(cap), "rate": int.parse(rate), "fail_upper_rate": double.parse(failUpperRate), "key": path});
}

Future<void> delConfig(String tenant, path) async {
  final resp = await dio.delete("/configs/$tenant", data: {"key": path});
}

Future<void> createApply(String tenant) async {
  final resp = await dio.post("/permission/$tenant");
}

Future<void> allowApply(String user, tenant) async {
  final resp = await dio.put("/permission/$tenant", data: {"user": user});
}

void main() async {
  print(await login("1@qq.com", "123"));
  print(await getTenant("test"));
  print(await getConfigs("233", "/test_config1"));
  print(await getMyApply());
  print(await getOtherApply());
}
