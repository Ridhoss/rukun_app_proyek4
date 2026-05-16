import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/rw/iuran/iuran_page_viewmodel.dart';

class RwIuranPage extends StatefulWidget {
  final User user;

  const RwIuranPage({super.key, required this.user});

  @override
  State<RwIuranPage> createState() => _RwIuranPageState();
}

class _RwIuranPageState extends State<RwIuranPage> {
  @override
  void initState() {
    super.initState();

    final rwId = widget.user.rw?.id;

    if (rwId == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RwIuranViewModel>().fetchDashboard(rwId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: "",
        title: "Dashboard Iuran RW",
        subtitle: "Daftar Iuran dalam wilayah RW",
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),

      body: Consumer<RwIuranViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = vm.iurans;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStaticToggle(),
                const SizedBox(height: 14),
                _buildStaticFilter(),
                const SizedBox(height: 14),
                _buildStaticInfo(),
                const SizedBox(height: 20),
                _buildTopAction(),
                const SizedBox(height: 16),

                ...data.map((iuran) {
                  return _buildIuranCard(iuran);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaticToggle() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              "RW",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            alignment: Alignment.center,
            child: const Text("RT"),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticFilter() {
    return Row(
      children: [
        _buildFilterChip("Semua", false),
        const SizedBox(width: 8),
        _buildFilterChip("Rutin", true),
        const SizedBox(width: 8),
        _buildFilterChip("Khusus", false),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: const Icon(Icons.tune, size: 18),
        ),
      ],
    );
  }

  Widget _buildStaticInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "2 setoran menunggu konfirmasi\nRT 02 & RT 04 sudah upload bukti",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
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
      child: Text(text),
    );
  }

  Widget _buildTopAction() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Daftar Iuran",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            // TODO: tambah iuran
          },
          icon: const Icon(Icons.add),
          label: const Text("Tambah"),
        ),
      ],
    );
  }

  Widget _buildIuranCard(Iuran item) {
    final jumlah = item.jumlah ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.nama,
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

          Text(
            "Rp $jumlah",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          Row(
            children: const [
              Text(
                "Iuran aktif",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
