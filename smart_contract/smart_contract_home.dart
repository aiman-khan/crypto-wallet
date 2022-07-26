import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rigel_fyp_project/widgets/slider_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class SmartContract extends StatefulWidget {
  const SmartContract({Key? key}) : super(key: key);

  @override
  State<SmartContract> createState() => _SmartContractState();
}

class _SmartContractState extends State<SmartContract> {
  late Client httpClient;
  late Web3Client ethClient;
  var txHash;
  var myData;
  int myAmount = 0;
  bool data = false;


  final myAddress = '0xDDCeC1a9881a2EF93C784edDe25C96ce413bFf36';

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://ropsten.infura.io/v3/1530e2d89ff74a58807de36d56485a6b",
        httpClient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x2F2F6f337Fa0BCefda1e6C029ab93aa91A0260a4";

    final contract = DeployedContract(ContractAbi.fromJson(abi, "MyRigel"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);

    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getBalance", []);

    myData = result[0];
    data = true;
    setState(() {});
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "b66c68a3be1cd129bc3c6480b85886d808d11901dd613d1957fc9109d50bac0b");

    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: ethFunction, parameters: args),
        fetchChainIdFromNetworkId: true);
    return result;
  }

  Future<String> sendCoin() async {
    var bigAmount = BigInt.from(myAmount);

    var response = await submit("depositBalance", [bigAmount]);

    print("Deposited");
    txHash = response;
    setState(() {});
    return response;
  }

  Future<String> withdrawCoin() async {
    var bigAmount = BigInt.from(myAmount);

    var response = await submit("withdrawBalance", [bigAmount]);

    print("Withdrawn");
    txHash = response;
    setState(() {});
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.gray300,
      body: ZStack(
        [
          VxBox()
              .blue600
              .size(context.screenWidth, context.percentHeight * 30)
              .make(),
          VStack([
            (context.percentHeight * 10).heightBox,
            "Transactions".text.xl4.white.bold.center.makeCentered().py16(),
            (context.percentHeight * 5).heightBox,
            VxBox(
                child: VStack([
                  "Balance".text.gray700.xl2.semiBold.makeCentered(),
                  10.heightBox,
                  data
                      ? "\$$myData".text.bold.xl6.makeCentered().shimmer(
                      primaryColor: Vx.blue800, secondaryColor: Vx.gray600)
                      : CircularProgressIndicator().centered()
                ]))
                .p16
                .white
                .size(context.screenWidth, context.percentHeight * 18)
                .rounded
                .shadowXl
                .make()
                .p16(),
            30.heightBox,
            SliderWidget(
              min: 0,
              max: 100,
              finalVal: (value) {
                myAmount = (value * 100).round();
                print(myAmount);
              },
            ).centered(),
            Wrap(
              children: [
                FlatButton.icon(
                  onPressed: () => sendCoin(),
                  color: Colors.green,
                  shape: Vx.roundedSm,
                  icon: Icon(
                    Icons.call_made,
                    color: Colors.white,
                  ),
                  label: "Deposit".text.white.make(),
                ).h(50),
                FlatButton.icon(
                  onPressed: () => withdrawCoin(),
                  color: Colors.red,
                  shape: Vx.roundedSm,
                  icon: Icon(
                    Icons.call_received,
                    color: Colors.white,
                  ),
                  label: "Withdraw".text.white.make(),
                ).h(50),
                FlatButton.icon(
                  onPressed: () => getBalance(myAddress),
                  color: Colors.blue,
                  shape: Vx.roundedSm,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  label: "Refesh".text.white.make(),
                ).h(50),
              ],
              alignment: WrapAlignment.center,
              spacing: 10.0,
              runSpacing: 10.0,
            ).centered().p16(),
          ]),
          if (txHash != null)
            Positioned(
                bottom: -550.0,
                child: "Last Transaction Hash: $txHash"
                    .text
                    .makeCentered()
                    .p16()
                    .whFull(context))
        ],
        fit: StackFit.loose,
      ),
    );
  }
}
