import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/rw/iuran/iuran_page_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/iuran/crud/add_iuran_page.dart';
import 'package:rukun_app_proyek4/views/pages/iuran/detail_iuran_rt_page.dart';
import 'package:rukun_app_proyek4/views/pages/rw/iuran/detail_iuran_rw_page.dart';

class PengurusIuranPage extends StatefulWidget {
  final User user;

  const PengurusIuranPage({super.key, required this.user});

  @override
  State<PengurusIuranPage> createState() => _PengurusIuranPageState();
}

class _PengurusIuranPageState extends State<PengurusIuranPage> {
  @override
  void initState() {
    super.initState();

    final rwId = widget.user.rw?.id;

    if (rwId == null) {
      Future.microtask(() {
        NotificationUtils.showError(context, "Rw Tidak Ditemukan");
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RwIuranViewModel>().fetchDashboard(rwId);
    });
  }

  String getAppBarTitle(DashboardMode mode) {
    switch (mode) {
      case DashboardMode.rw:
        return "Dashboard Iuran RW";
      case DashboardMode.rt:
        return "Dashboard Iuran RT";
    }
  }

  String getAppBarSubtitle(DashboardMode mode) {
    switch (mode) {
      case DashboardMode.rw:
        return "Daftar Iuran dalam wilayah RW";
      case DashboardMode.rt:
        return "Daftar Iuran dalam wilayah RT";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RwIuranViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),

          appBar: AppBarUtils.buildAppBar(
            context: context,
            name: "",
            title: getAppBarTitle(vm.mode),
            subtitle: getAppBarSubtitle(vm.mode),
            showName: false,
            showAvatar: false,
            showGreeting: false,
          ),

          body: _buildBody(vm),
        );
      },
    );
  }

  Widget _buildBody(RwIuranViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = vm.filteredIurans;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStaticToggle(vm),
          const SizedBox(height: 14),
          _buildStaticFilter(vm),
          const SizedBox(height: 20),
          _buildTopAction(vm),
          const SizedBox(height: 16),

          if (data.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    vm.mode == DashboardMode.rt
                        ? "Belum ada iuran tingkat RT"
                        : "Belum ada iuran tingkat RW",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    vm.mode == DashboardMode.rt
                        ? "Iuran RT akan muncul di sini"
                        : "Iuran RW akan muncul di sini",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ...data.map((iuran) => _buildIuranCard(iuran)),
        ],
      ),
    );
  }

  Widget _buildStaticToggle(RwIuranViewModel vm) {
    final isRW = vm.mode == DashboardMode.rw;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              vm.setMode(DashboardMode.rw);
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isRW ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              alignment: Alignment.center,
              child: Text(
                "RW",
                style: TextStyle(
                  color: isRW ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: GestureDetector(
            onTap: () {
              vm.setMode(DashboardMode.rt);
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: !isRW ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              alignment: Alignment.center,
              child: Text(
                "RT",
                style: TextStyle(
                  color: !isRW ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticFilter(RwIuranViewModel vm) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => vm.setFilter(IuranFilter.semua),
          child: _buildFilterChip(
            "Semua",
            vm.selectedFilter == IuranFilter.semua,
          ),
        ),

        const SizedBox(width: 8),

        GestureDetector(
          onTap: () => vm.setFilter(IuranFilter.rutin),
          child: _buildFilterChip(
            "Rutin",
            vm.selectedFilter == IuranFilter.rutin,
          ),
        ),

        const SizedBox(width: 8),

        GestureDetector(
          onTap: () => vm.setFilter(IuranFilter.khusus),
          child: _buildFilterChip(
            "Khusus",
            vm.selectedFilter == IuranFilter.khusus,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String text, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTopAction(RwIuranViewModel vm) {
    final isRWMode = vm.mode == DashboardMode.rw;

    final level = widget.user.pengurus?.level.toLowerCase();

    final isUserRW = level == "rw";
    final isUserRT = level == "rt";

    final canAdd = (isRWMode && isUserRW) || (!isRWMode && isUserRT);

    return Row(
      children: [
        Expanded(
          child: Text(
            isRWMode ? "Daftar Iuran RW" : "Daftar Iuran RT",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        if (canAdd)
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddIuranPage(user: widget.user),
                ),
              ).then((result) {
                if (result == true) {
                  final rwId = widget.user.rw?.id;

                  if (rwId != null) {
                    context.read<RwIuranViewModel>().fetchDashboard(rwId);
                  }
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text("Tambah"),
          ),
      ],
    );
  }

  Widget _buildIuranCard(Iuran item) {
    final jumlah = item.jumlah ?? 0;

    return GestureDetector(
      onTap: () {
        final id = item.id;
        if (id == null) {
          return;
        }

        final level = widget.user.pengurus?.level.toLowerCase();

        if (level == "rw") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IuranRWDetailPage(id: id, user: widget.user),
            ),
          );
          return;
        }

        if (level == "rt") {
          final rtId = widget.user.rt?.id;

          if (rtId == null) {
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  IuranRTDetailPage(iuranId: id, rtId: rtId, user: widget.user),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.level == IuranLevel.rt
                        ? "${item.nama} - RT ${item.rt?.noRt ?? '-'}"
                        : item.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: item.tipe == IuranType.reguler
                        ? Colors.blue
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.tipe.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (item.tipe != IuranType.insidentil)
              Text(
                "Biaya Iuran: Rp $jumlah",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

            const SizedBox(height: 10),

            Text(
              "Dibuat: ${item.waktuDibuat != null ? DateFormat('dd MMMM yyyy', 'id_ID').format(item.waktuDibuat!) : '-'}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            Text(
              "Terkumpul: Rp.${item.totalTerkumpul ?? 0}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 6),

            Chip(
              label: Text(
                (item.isActive ?? false) ? 'Iuran Aktif' : 'Iuran Non-Aktif',
              ),
              labelStyle: TextStyle(color: Colors.white, fontSize: 12),
              backgroundColor: (item.isActive ?? false)
                  ? Colors.green
                  : Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
          ],
        ),
      ),
    );
  }
}
