import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../elements/DeliveryAddressBottomSheetWidget.dart';
import '../../repository/settings_repository.dart' as settingsRepo;

class HomeDeliveryPickupSection extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final VoidCallback onRefresh;

  const HomeDeliveryPickupSection({
    Key? key,
    required this.scaffoldKey,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    S.of(context).top_restaurants,
                    style: Theme.of(context).textTheme.headlineLarge,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
                InkWell(
                  onTap: () {
                    var controller = scaffoldKey?.currentState?.showBottomSheet(
                          (context) => DeliveryAddressBottomSheetWidget(
                        scaffoldKey: scaffoldKey!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                    );
                    controller?.closed.then((_) => onRefresh());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: settingsRepo.deliveryAddress.value.address == null
                          ? Theme.of(context).focusColor.withOpacity(0.1)
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    child: Text(
                      S.of(context).delivery,
                      style: TextStyle(
                        color: settingsRepo.deliveryAddress.value.address == null
                            ? Theme.of(context).hintColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 7),
                InkWell(
                  onTap: () {
                    settingsRepo.deliveryAddress.value.address = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: settingsRepo.deliveryAddress.value.address != null
                          ? Theme.of(context).focusColor.withOpacity(0.1)
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    child: Text(
                      S.of(context).pickup,
                      style: TextStyle(
                        color: settingsRepo.deliveryAddress.value.address != null
                            ? Theme.of(context).hintColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (settingsRepo.deliveryAddress.value.address != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  S.of(context).near_to + " " + settingsRepo.deliveryAddress.value.address!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}