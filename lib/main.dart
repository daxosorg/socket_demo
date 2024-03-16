import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Socket Demo')),
        body: const OrderBookWidget(),
      ),
    );
  }
}

class OrderBookWidget extends StatefulWidget {
  const OrderBookWidget({super.key});

  @override
  _OrderBookWidgetState createState() => _OrderBookWidgetState();
}

class _OrderBookWidgetState extends State<OrderBookWidget> {
  final channel = WebSocketChannel.connect(Uri.parse('ws://stream.bit24hr.in:8765/btc_order_book'));
  List<dynamic> buyOrders = [];
  List<dynamic> sellOrders = [];

  @override
  void initState() {
    super.initState();
    channel.stream.listen((data) {
      try {
        final orderBookData = jsonDecode(data);
        final buyOrders = orderBookData['bids'];
        final sellOrders = orderBookData['asks'];
        setState(() {
          this.buyOrders = buyOrders;
          this.sellOrders = sellOrders;
        });
      } catch (error) {
        debugPrint('Error parsing data: $error');
      }
    }, onError: (error) {
      debugPrint('WebSocket error: $error');
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                color: Colors.green,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Text("Buy orders"),
                    const SizedBox(height: 10),
                    ...buyOrders.map((order) => OrderTile(order: order)).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              flex: 1,
              child: Container(
                color: Colors.red,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Text("Sell orders"),
                    const SizedBox(height: 10),
                    ...sellOrders.map((order) => OrderTile(order: order)).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final List<dynamic> order;

  const OrderTile({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final price = order[0];
    final volume = order[1];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(price.toStringAsFixed(2)),
        Text(volume.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
