import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/models/iuran/rw/rt_iuran_detail_rw_model.dart';

class IuranRWDetail {
  final Iuran iuran;
  final Map<String, dynamic> summary;
  final List<RtIuranDetailRW> rtList;

  IuranRWDetail({
    required this.iuran,
    required this.summary,
    required this.rtList,
  });

  factory IuranRWDetail.fromJson(Map<String, dynamic> json) {
    return IuranRWDetail(
      iuran: Iuran.fromJson(json),

      summary: Map<String, dynamic>.from(json['summary'] ?? {}),

      rtList: List<RtIuranDetailRW>.from(
        (json['rt_list'] ?? []).map(
          (e) => RtIuranDetailRW.fromJson(Map<String, dynamic>.from(e)),
        ),
      ),
    );
  }
}
