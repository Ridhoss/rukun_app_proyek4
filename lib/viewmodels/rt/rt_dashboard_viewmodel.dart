import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/rt/rt_dashboard_model.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_rt_dashboard_service.dart';

class RtDashboardViewModel extends ChangeNotifier {
  final CloudRtDashboardService _service = CloudRtDashboardService();

  RtDashboardModel? _dashboardData;
  RtDashboardModel? get dashboardData => _dashboardData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboard(int rtId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _service.fetchDashboardData(rtId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}