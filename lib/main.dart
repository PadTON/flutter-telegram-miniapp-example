// ignore_for_file: avoid_web_libraries_in_flutter, avoid_print

import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:js/js.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:web_test/model.dart';

@JS()
external String connectTonWallet();

@JS()
external disconnectTonWallet();

@JS()
external deposit(String senderAddress, String destinationAddress, String amountInTon, String comment, bool useTon);

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.cupertino(
      title: 'Flutter Web App',
      debugShowCheckedModeBanner: false,
      cupertinoThemeBuilder: (context, theme) {
        return theme.copyWith(applyThemeToAll: true, primaryColor: Colors.blue);
      },
      home: const MyHomePage(),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child,
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formKey = GlobalKey<ShadFormState>();

  String telegramId = "";
  String walletAddress = "";
  String walletImage = "";
  String address = "";
  String amount = "";
  String comment = "";
  String token = "TON";
  String version = "Unknown";

  @override
  void initState() {
    super.initState();

    // // Fetch Telegram ID from Telegram Web App context
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        // Fetch Telegram ID from Telegram Web App context
        final telegramWebApp = js.context['Telegram']['WebApp'];
        if (telegramWebApp != null) {
          telegramId = telegramWebApp['initDataUnsafe']['user']['id'].toString();
        }
      } catch (e) {
        //
      }

      // fetch connected wallet
      final jsonWallet = getFromLocalStorage("CONNECTED_WALLET");
      if (jsonWallet != null && jsonWallet.isNotEmpty) {
        final wallet = RemoteMobileNode.fromJson(json.decode(jsonWallet));
        setState(() {
          final walletAddressHex = wallet.account?.address ?? "";
          final parts = walletAddressHex.split(":");
          if (parts.length > 1) {
            walletAddress = TonAddress.fromBytes(
              int.tryParse(parts[0]) ?? 0,
              hex.decode(parts[1]),
              bounceable: false,
              testNet: true,
            ).toFriendlyAddress();
          } else {
            walletAddress = walletAddressHex;
          }
          walletImage = wallet.imageUrl ?? "";
        });
      }
    });
  }

  void saveToLocalStorage(String key, String value) {
    html.window.localStorage[key] = value;
  }

  String? getFromLocalStorage(String key) {
    return html.window.localStorage[key];
  }

  Future<void> _onDeposit() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:6969/deposit'),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: '{"telegramId": "$telegramId"}',
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final depositAddress = jsonResponse["address"];
        final comment = jsonResponse["comment"];
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Deposit Information"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'It is very easy to top up your balance here.\nSimply send any amount of TON to this address:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        depositAddress,
                        style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'And include the following comment:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        comment,
                        style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              });
        }
      } else {}
    } catch (e) {
      // handle error
    }
  }

  void _onConnect() async {
    try {
      final jsonWallet = await promiseToFuture(connectTonWallet());
      final wallet = RemoteMobileNode.fromJson(json.decode(jsonWallet));
      setState(() {
        final walletAddressHex = wallet.account?.address ?? "";
        final parts = walletAddressHex.split(":");
        if (parts.length > 1) {
          walletAddress = TonAddress.fromBytes(
            int.tryParse(parts[0]) ?? 0,
            hex.decode(parts[1]),
            bounceable: false,
            testNet: true,
          ).toFriendlyAddress();
        } else {
          walletAddress = walletAddressHex;
        }
        walletImage = wallet.imageUrl ?? "";
      });
      saveToLocalStorage("CONNECTED_WALLET", jsonWallet);
    } catch (e) {
      print(e);
    }
  }

  void _onDisconnect() async {
    try {
      await disconnectTonWallet();
      setState(() {
        walletAddress = "";
      });
      saveToLocalStorage("CONNECTED_WALLET", "");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text(
          'Flutter Web App',
          style: ShadTheme.of(context).textTheme.h4,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Row(),
            const SizedBox(height: 20),
            if (walletAddress.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      walletImage,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Your TON Address:",
                    style: ShadTheme.of(context).textTheme.small,
                  ),
                ],
              ),
              SelectableText(
                walletAddress,
                style: ShadTheme.of(context).textTheme.p.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildDepositButton(),
              const SizedBox(height: 20),
              ShadButton.outline(
                onPressed: _onDisconnect,
                width: 200,
                icon: const Icon(Icons.link_off_sharp),
                text: const Text('Disconnect Wallet'),
              ),
            ] else
              ShadButton(
                width: 200,
                onPressed: _onConnect,
                icon: const Icon(Icons.wallet),
                text: const Text('Connect Wallet'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  ShadButton _buildDepositButton() {
    return ShadButton(
      onPressed: () {
        if (walletAddress.isEmpty) {
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text('Wallet Connection'),
              description: const Text('You have to connect to TON Wallet before making a deposit'),
              action: ShadButton.outline(
                text: const Text('Okay'),
                onPressed: () => ShadToaster.of(context).hide(),
              ),
            ),
          );
          return;
        }
        showShadDialog(
          context: context,
          builder: (context) => ShadDialog(
            title: const Text('Deposit'),
            content: ShadForm(
              key: formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShadSelectFormField<String>(
                      id: 'token',
                      initialValue: token,
                      options: ["TON", "CANNA"].map((token) => ShadOption(value: token, child: Text(token))).toList(),
                      selectedOptionBuilder: (context, value) =>
                          value == 'none' ? const Text('Select Token') : Text(value),
                      placeholder: const Text('Select Token'),
                      validator: (v) {
                        if (v == null) {
                          return 'Please select token';
                        }
                        return null;
                      },
                      onSaved: (v) {
                        token = v ?? "";
                      },
                    ),
                    ShadInputFormField(
                      id: 'address',
                      placeholder: const Text('Address'),
                      validator: (v) {
                        if (v.isEmpty) {
                          return 'Deposit address is required';
                        }
                        return null;
                      },
                      onSaved: (v) => address = v ?? "",
                    ),
                    ShadInputFormField(
                      id: 'comment',
                      placeholder: const Text('Comment'),
                      validator: (v) {
                        if (v.isEmpty) {
                          return 'Deposit comment is required';
                        }
                        return null;
                      },
                      onSaved: (v) => comment = v ?? "",
                    ),
                    ShadInputFormField(
                      id: 'amount',
                      placeholder: const Text('Amount'),
                      validator: (v) {
                        if (v.isEmpty) {
                          return 'Deposit amount is required';
                        }
                        return null;
                      },
                      onSaved: (v) => amount = v ?? "",
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ShadButton(
                text: const Text('Deposit'),
                onPressed: () {
                  if (formKey.currentState!.saveAndValidate()) {
                    Navigator.of(context).pop();
                    _onDeposit();
                  }
                },
              ),
            ],
          ),
        );
      },
      width: 200,
      icon: const Icon(Icons.upgrade_outlined),
      text: const Text('Deposit'),
    );
  }
}
