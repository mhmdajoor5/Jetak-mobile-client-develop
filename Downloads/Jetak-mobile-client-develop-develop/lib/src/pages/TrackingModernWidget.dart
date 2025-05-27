import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TrackingModernWidget extends StatelessWidget {
  const TrackingModernWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Tracking",
          style: TextStyle(
            fontFamily: "Nunito",
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF272727),
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFE7E7E9)),
            ),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ),

      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(child: Text("Map Here", style: TextStyle(fontSize: 20))),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage("assets/images/image-removebg-preview.png"),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Angel Donin",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.0,
                              letterSpacing: -0.02,
                              color: Color(0xFF272727),
                            ),
                          ),
                          SizedBox(height: 4,),
                          Text(
                            "Courier",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 1.4,
                              letterSpacing: -0.02,
                              color: Color(0xFF9D9FA4),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      _buildActionIconPhone(),
                      SizedBox(width: 10),
                      Stack(
                        children: [
                          _buildActionIconMassge(),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.red,
                              child: Text("3", style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) => Row(
                      children: List.generate((constraints.maxWidth / 10).floor(), (index) {
                        return Container(
                          width: 6,
                          height: 1,
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          color: Color(0xFFE7E7E9),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildStepProgress(),
                  ),
                  SizedBox(height: 20),
                  _buildInfoTile("Delivery time", "assets/img/clock.svg", "30 Minutes"),
                  _buildInfoTile("Delivery address", "assets/img/locationorder.svg", "6391 Elgin St. Celina, Delaware "),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    return Row(
      children: [
        _buildStepIcon('assets/img/receipt-item.svg', true),
        _buildDashedLine(true),
        _buildStepIcon('assets/img/reserve.svg', true),
        _buildDashedLine(false),
        _buildStepIcon('assets/img/truck-fast.svg', false),
        _buildDashedLine(false),
        _buildStepIcon('assets/img/tick-circle.svg', false),
      ],
    );
  }

  Widget _buildDashedLine(bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 5),
          Container(
            width: 8,
            height: 8,
            transform: Matrix4.rotationZ(0.785398),
            decoration: BoxDecoration(
              color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
              shape: BoxShape.rectangle,
            ),
          ),
          Row(
            children: List.generate(4, (index) {
              return Container(
                width: 3,
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 2),
                color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
              );
            }),
          ),
          SizedBox(width: 7),
          Container(
            width: 8,
            height: 8,
            transform: Matrix4.rotationZ(0.785398),
            decoration: BoxDecoration(
              color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
              shape: BoxShape.rectangle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(String svgAsset, bool active) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: active ? Color(0xFF26386A) : Colors.white,
        border: Border.all(
          color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
          width: 1,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          svgAsset,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            active ? Colors.white : Color(0xFF26386A),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String svgAsset, String text) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 12),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFE7E7E9)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SvgPicture.asset(
                  svgAsset,
                  width: 20,
                  height: 20,
                  // color: Colors.white,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF272727),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          top: 0,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A2A8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionIconPhone() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFFE7E7E9), width: 1),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/img/vector.svg',
          width: 20,
          height: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildActionIconMassge() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFFE7E7E9), width: 1),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/img/message-text.svg',
          width: 20,
          height: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}
