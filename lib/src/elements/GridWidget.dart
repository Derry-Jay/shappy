import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shappy/src/models/store_category.dart';
import '../elements/GridItemWidget.dart';

class GridWidget extends StatelessWidget {
  final List<StoreCategory> categoryList;
  final String heroTag;
  GridWidget({Key key, this.categoryList, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return new StaggeredGridView.countBuilder(
      physics: NeverScrollableScrollPhysics(),
      primary: false,
      shrinkWrap: true,
      crossAxisCount: 4,
      itemCount: categoryList.length,
      itemBuilder: (BuildContext context, int index) {
        return GridItemWidget(
            category: categoryList.elementAt(index), heroTag: heroTag);
      },
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(
          MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4),
      mainAxisSpacing: MediaQuery.of(context).size.height / 50,
      crossAxisSpacing: MediaQuery.of(context).size.width / 30,
    );
  }
}
