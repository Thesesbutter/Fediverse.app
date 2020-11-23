import 'dart:async';

import 'package:fedi/app/captcha/pleroma/pleroma_form_captcha_string_field_bloc.dart';
import 'package:fedi/form/field/value/string/string_value_form_field_bloc_impl.dart';
import 'package:fedi/form/field/value/value_form_field_validation.dart';
import 'package:fedi/pleroma/captcha/native/pleroma_native_captcha_image_extension.dart';
import 'package:fedi/pleroma/captcha/pleroma_captcha_model.dart';
import 'package:fedi/pleroma/captcha/pleroma_captcha_service.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

final checkCaptchaExpiredPeriodicDuration = Duration(seconds: 5);

class PleromaFormCaptchaStringFieldBloc extends StringValueFormFieldBloc
    implements IPleromaFormCaptchaStringFieldBloc {
  final IPleromaCaptchaService pleromaCaptchaService;

  final BehaviorSubject<PleromaCaptcha> captchaSubject;

  @override
  PleromaCaptcha get captcha => captchaSubject.value;

  @override
  Stream<PleromaCaptcha> get captchaStream => captchaSubject.stream;

  final BehaviorSubject<DateTime> captchaLoadedDateTimeSubject;

  @override
  DateTime get captchaLoadedDateTime => captchaLoadedDateTimeSubject.value;

  @override
  Stream<DateTime> get captchaLoadedDateTimeStream =>
      captchaLoadedDateTimeSubject.stream;

  PleromaFormCaptchaStringFieldBloc(
      {@required this.pleromaCaptchaService,
      @required PleromaCaptcha initialCaptcha,
      @required String originValue,
      @required List<FormValueFieldValidation<String>> validators})
      : captchaSubject = BehaviorSubject.seeded(initialCaptcha),
        captchaLoadedDateTimeSubject = BehaviorSubject.seeded(DateTime.now()),
        super(
          originValue: originValue,
          validators: validators,
          maxLength: null,
        ) {
    addDisposable(subject: captchaSubject);
    addDisposable(subject: captchaLoadedDateTimeSubject);
    addDisposable(
      timer: Timer.periodic(
        checkCaptchaExpiredPeriodicDuration,
        (timer) {
          if (captchaLoadedDateTime != null && captcha != null) {
            if (captchaLoadedDateTime
                        .difference(DateTime.now())
                        .abs()
                        .inSeconds +
                    checkCaptchaExpiredPeriodicDuration.inSeconds >
                captcha.secondsValid) {
              reloadCaptcha();
            }
          }
        },
      ),
    );
  }

  @override
  Stream<Image> get captchaImageStream =>
      captchaStream.asyncMap((captcha) async {
        switch (captcha?.pleromaType) {
          case PleromaCaptchaType.kocaptcha:
          case PleromaCaptchaType.unknown:
            return Image.network(captcha.url);
            break;
          case PleromaCaptchaType.native:
            return captcha.decodeUrlAsBase64Image();
            break;
          default:
            return null;
        }
      });

  @override
  Future reloadCaptcha() async {
    captchaSubject.add(null);
    captchaLoadedDateTimeSubject.add(null);
    var captcha = await pleromaCaptchaService.getCaptcha();
    captchaLoadedDateTimeSubject.add(DateTime.now());
    captchaSubject.add(captcha);
  }
}