import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:console/console.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/main.dart';
import 'package:mobile_application/providers/authentication/authentication_provider.dart';
import 'package:mobile_application/providers/chat/chat_provider.dart';
import 'package:mobile_application/providers/configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  test("dynamic input", () async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    var shell = ShellPrompt();

    /// Creation of all needed data for the http manager
    var options = BaseOptions(
      baseUrl: Configuration.serverUrl,
      receiveTimeout: 8000,
      sendTimeout: 5000,
    );

    // Setup the Http manager
    Dio _httpManager = Dio(options);
    (_httpManager.transformer as DefaultTransformer).jsonDecodeCallback =
        parseJson;

    SecurityContext securityContext = SecurityContext.defaultContext;
    List<int> bytes = utf8.encode(
      """-----BEGIN CERTIFICATE-----
MIIEGzCCAwOgAwIBAgIUBTe6TF/7odAsZUM1FE1MxMyd83EwDQYJKoZIhvcNAQEL
BQAwgY8xCzAJBgNVBAYTAmFhMQ8wDQYDVQQIDAZyYW5kb20xDzANBgNVBAcMBnJh
bmRvbTEPMA0GA1UECgwGcmFuZG9tMQ8wDQYDVQQLDAZyYW5kb20xGjAYBgNVBAMM
EWxvY2FsIENlcnRpZmljYXRlMSAwHgYJKoZIhvcNAQkBFhFyYW5kb21AcmFuZG9t
LmNvbTAeFw0xOTA4MTkwMDIwMTJaFw0yMDEyMzEwMDIwMTJaMIGsMQswCQYDVQQG
EwJVUzEUMBIGA1UECAwLUmFuZG9tU3RhdGUxEzARBgNVBAcMClJhbmRvbUNpdHkx
GzAZBgNVBAoMElJhbmRvbU9yZ2FuaXphdGlvbjEfMB0GA1UECwwWUmFuZG9tT3Jn
YW5pemF0aW9uVW5pdDEgMB4GCSqGSIb3DQEJARYRaGVsbG9AZXhhbXBsZS5jb20x
EjAQBgNVBAMMCWxvY2FsaG9zdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
ggEBAK6UkgOUCowtGFW3OO2jzunFyokc7KREtaHwPU2ixxXxDUA9Q+s81gMmnWVj
uzgn94vuUcjTOR3V+xHkXCpfafdLBrhmmd9w/VZhoAca02VpKOvaM40VWXZ0rLAW
VAUjOqG1YFDeNUJ4nl1ixkOfLaUDmhr3VXtLTHgxZ1Stt4JjEQAz4F0+oXJpo1cB
aGQfFViKf7NGSjAjYVlLWxX9iWVRTm7tEh7mDGRIo50tTciyuYl/i9wJiWZvnOrl
CbEKH9Cq5GEjqZswpT0ks9qFhtTOtsSY/g1PyTj79Eghh3rr/Zuwt9O7sNF6hUYs
vPR8xGqHMGAKmtKf9MroJML2IacCAwEAAaNQME4wKgYDVR0RBCMwIYIJbG9jYWxo
b3N0gghib2lzLmNvbYcEfwAAAYcECgACAjALBgNVHQ8EBAMCB4AwEwYDVR0lBAww
CgYIKwYBBQUHAwEwDQYJKoZIhvcNAQELBQADggEBAJuI6lYFMpJt5J9RyX5nIx+R
PgLR3LtXwJVmVIpAedb9FtxWTYKalP3HpOpxjyUgSRIcNGDRBf0c10wXJh+2AysO
3G0ZUUTb0uMiW302Q5RYfIbxnqR/KX0mJ+MegcT4ZiF62S3OihWKVDe9vtYr9Ss/
hv3h9jC0gxDP4L+v4VzIkkNqzpa7EDKJl1LCYk06i8Ip+whgDQYs9YxfoLMzOUzP
vvYJ516ZsHNR9HvvKiQFFmkeYlQgOzUGv6sB9GkJCKVmgDY2isJTRTNVR3Zibfe2
0rSXEcRgPtLvKp7mmoNaSL2SDhw+wr0ZR6dlH8DuiSNLsFtQ0kQr6i2sf0syudI=
-----END CERTIFICATE-----
""",
    );
    securityContext.setTrustedCertificatesBytes(bytes);

    (_httpManager.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) => HttpClient(context: securityContext);

    var authenticationProvider = AuthenticationProvider(_httpManager);
    authenticationProvider.token =
        "68eac7d55c2877ecf9e6153e393efef2218a768b8086dc5bdf2faa11d9600bb9c710edbe4d8fc9d740fe65eab1386a68f9519a7d2262bac7d0ad2b4eec98773165bc9e5be7ec925a0958a470a67ed218f3a94eb23edf1e2e1715c538e661849ed5ac22ad84235b793e6395d018ae2aba82eefa51d27f3453385e8886f86f0755bbeb63cc5159c2446b32057967e3923e1a467410b82b520b8c9d61d924093b512d5f18e80b17d60ac166ac6394b8567c018d6ef708c43ebd38295dc4fea2958625fdef1b4ba92fc4a105d8bb4de523b9b591a63ca05f26430424b8f5ccb18ef15428c24aea86ccc06e7578fd7f0970da39756753d9ff66bb7d8f7a8611ae04de";
    var chatProvider = ChatProvider(authenticationProvider.httpRequestWrapper);
    await chatProvider.initializeChatProvider(
      authToken:
          "68eac7d55c2877ecf9e6153e393efef2218a768b8086dc5bdf2faa11d9600bb9c710edbe4d8fc9d740fe65eab1386a68f9519a7d2262bac7d0ad2b4eec98773165bc9e5be7ec925a0958a470a67ed218f3a94eb23edf1e2e1715c538e661849ed5ac22ad84235b793e6395d018ae2aba82eefa51d27f3453385e8886f86f0755bbeb63cc5159c2446b32057967e3923e1a467410b82b520b8c9d61d924093b512d5f18e80b17d60ac166ac6394b8567c018d6ef708c43ebd38295dc4fea2958625fdef1b4ba92fc4a105d8bb4de523b9b591a63ca05f26430424b8f5ccb18ef15428c24aea86ccc06e7578fd7f0970da39756753d9ff66bb7d8f7a8611ae04de",
      userId: "5e25a28b249f1c04fc51a07d",
    );

    StreamController i = StreamController.broadcast();

    shell.loop().listen((line) {
      chatProvider.sendTypingNotification("5e28d2d2715a4352708b4712");
      if (["stop", "quit", "exit"].contains(line.toLowerCase().trim())) {
        expect(1, 1);
        shell.stop();
        i.close();
        return;
      }
      print(line);
    });

    await for (dynamic _ in i.stream) {}
    ;

    print("dai oh");
  });
}
