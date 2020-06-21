import 'package:fedi/app/ui/fedi_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FediFilledEditTextField extends StatelessWidget {
  final String hintText;
  final bool expanded;
  final bool autofocus;
  final TextEditingController textEditingController;
  final Widget leading;
  final Widget ending;
  final FocusNode focusNode;
  final int maxLines;
  final ValueChanged<String> onSubmitted;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;

  FediFilledEditTextField({
    @required this.textEditingController,
    @required this.hintText,
    @required this.maxLines,
    @required this.onSubmitted,
    @required this.textInputAction,
    this.leading,
    this.ending,
    @required this.expanded,
    @required this.autofocus,
    this.focusNode,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    var containLeading = leading != null;
    var containEnding = ending != null;
    return Container(
      decoration: BoxDecoration(
          color: FediColors.ultraLightGrey,
          borderRadius: BorderRadius.circular(30.0)),
      child: Padding(
        padding: calculatePadding(containLeading, containEnding),
        child: Row(
          children: [
            if (containLeading) leading,
            Flexible(
              child: TextField(
                focusNode: focusNode,
                textInputAction:
                    maxLines == 1 ? textInputAction : TextInputAction.newline,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(
                      fontSize: 16.0, color: FediColors.grey, height: 1.5),
                ),
                style: TextStyle(
                    fontSize: 16.0, color: FediColors.darkGrey, height: 1.5),
                autofocus: autofocus,
                controller: textEditingController,
                minLines: null,
                maxLines: maxLines,
                expands: expanded,
                keyboardType: keyboardType,
              ),
            ),
            if (containEnding) ending,
          ],
        ),
      ),
    );
  }

  EdgeInsets calculatePadding(bool containLeading, bool containEnding) {
    if (containLeading && containEnding) {
      return const EdgeInsets.all(0.0);
    } else {
      if (!containLeading && !containEnding) {
        return const EdgeInsets.symmetric(horizontal: 16.0);
      } else {
        if (containLeading) {
          return const EdgeInsets.only(right: 16.0);
        } else {
          return const EdgeInsets.only(left: 16.0);
        }
      }
    }
  }
}