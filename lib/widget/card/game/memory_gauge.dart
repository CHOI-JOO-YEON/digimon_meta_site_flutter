import 'package:flutter/material.dart';

class MemoryGauge extends StatefulWidget {
  const MemoryGauge({super.key});

  @override
  _MemoryGaugeState createState() => _MemoryGaugeState();
}

class _MemoryGaugeState extends State<MemoryGauge> {
  int? selectedMemory; // 현재 선택된 메모리 값

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(21, (index) {
        int value = index - 10; // -10 ~ 10 범위
        bool isSelected = selectedMemory == value;
    
        Color bgColor;
        if (isSelected) {
          bgColor =
              const Color.fromRGBO(168, 230, 209, 1); // 오른쪽(나) & 0은 중립
        } else {
          bgColor = value == 0
              ? Colors.grey[300]!
              : (value < 0 ? Colors.white : Colors.blueAccent);
        }
    
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedMemory = (selectedMemory == value) ? null : value;
            });
          },
          child: Container(
            height: 40,
            width: 40,
            // margin: const EdgeInsets.symmetric(horizontal: 2),
            // padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, 4),
                  ),
                ]
            ),
            child: Center(
              child: Text(
                value.abs().toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }),
    );
  }
}
