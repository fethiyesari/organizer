import 'package:flutter/material.dart';

class MyCardTile extends StatelessWidget {
  final String tileTitle;
  final VoidCallback onTap;

  const MyCardTile({
    Key? key,
    required this.tileTitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Kart tıklandığında çalışacak fonksiyon
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tileTitle,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}