import 'package:flutter/material.dart';

void main() {
  runApp(const HRDashboardApp());
}

class HRDashboardApp extends StatelessWidget {
  const HRDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HR Roster Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HRDashboardScreen(),
      },
    );
  }
}

class Employee {
  final String id;
  final String name;
  final String factoryLocation;
  final String department;
  final String education;
  final bool isWorking;

  Employee({
    required this.id,
    required this.name,
    required this.factoryLocation,
    required this.department,
    required this.education,
    required this.isWorking,
  });
}

// Mock Master Data
final List<Employee> masterData = [
  Employee(id: 'E001', name: 'Alice Smith', factoryLocation: 'Factory A', department: 'Production', education: 'BSc', isWorking: true),
  Employee(id: 'E002', name: 'Bob Johnson', factoryLocation: 'Factory A', department: 'QA', education: 'Diploma', isWorking: true),
  Employee(id: 'E003', name: 'Charlie Brown', factoryLocation: 'Factory B', department: 'Production', education: 'High School', isWorking: false),
  Employee(id: 'E004', name: 'Diana Prince', factoryLocation: 'Factory C', department: 'Management', education: 'MBA', isWorking: true),
  Employee(id: 'E005', name: 'Evan Davis', factoryLocation: 'Factory A', department: 'Logistics', education: 'BSc', isWorking: true),
  Employee(id: 'E006', name: 'Fiona Gallagher', factoryLocation: 'Factory B', department: 'HR', education: 'BA', isWorking: false),
  Employee(id: 'E007', name: 'George Miller', factoryLocation: 'Factory C', department: 'Production', education: 'Diploma', isWorking: true),
  Employee(id: 'E008', name: 'Hannah Abbott', factoryLocation: 'Factory A', department: 'QA', education: 'BSc', isWorking: true),
  Employee(id: 'E009', name: 'Ian Wright', factoryLocation: 'Factory B', department: 'Logistics', education: 'High School', isWorking: true),
  Employee(id: 'E010', name: 'Jane Doe', factoryLocation: 'Factory C', department: 'Management', education: 'MBA', isWorking: false),
];

class HRDashboardScreen extends StatefulWidget {
  const HRDashboardScreen({super.key});

  @override
  State<HRDashboardScreen> createState() => _HRDashboardScreenState();
}

class _HRDashboardScreenState extends State<HRDashboardScreen> {
  // Slicer States
  final Set<String> _selectedFactories = {};
  final Set<String> _selectedDepartments = {};
  final Set<String> _selectedEducation = {};
  bool? _isWorkingFilter; // null means all, true means active, false means inactive

  List<String> get _factories => masterData.map((e) => e.factoryLocation).toSet().toList()..sort();
  List<String> get _departments => masterData.map((e) => e.department).toSet().toList()..sort();
  List<String> get _educations => masterData.map((e) => e.education).toSet().toList()..sort();

  List<Employee> get _filteredData {
    return masterData.where((emp) {
      if (_selectedFactories.isNotEmpty && !_selectedFactories.contains(emp.factoryLocation)) return false;
      if (_selectedDepartments.isNotEmpty && !_selectedDepartments.contains(emp.department)) return false;
      if (_selectedEducation.isNotEmpty && !_selectedEducation.contains(emp.education)) return false;
      if (_isWorkingFilter != null && emp.isWorking != _isWorkingFilter) return false;
      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedFactories.clear();
      _selectedDepartments.clear();
      _selectedEducation.clear();
      _isWorkingFilter = null;
    });
  }

  Widget _buildFilterSection(String title, List<String> options, Set<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(option, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildWorkingStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Working Status', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 8.0,
          children: [
            ChoiceChip(
              label: const Text('All', style: TextStyle(fontSize: 12)),
              selected: _isWorkingFilter == null,
              onSelected: (selected) {
                if (selected) setState(() => _isWorkingFilter = null);
              },
            ),
            ChoiceChip(
              label: const Text('Active', style: TextStyle(fontSize: 12)),
              selected: _isWorkingFilter == true,
              onSelected: (selected) {
                if (selected) setState(() => _isWorkingFilter = true);
              },
            ),
            ChoiceChip(
              label: const Text('Inactive / Removed', style: TextStyle(fontSize: 12)),
              selected: _isWorkingFilter == false,
              onSelected: (selected) {
                if (selected) setState(() => _isWorkingFilter = false);
              },
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters (Slicers)', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterSection('Factory', _factories, _selectedFactories),
          _buildFilterSection('Department', _departments, _selectedDepartments),
          _buildFilterSection('Education', _educations, _selectedEducation),
          _buildWorkingStatusFilter(),
        ],
      ),
    );
  }

  Widget _buildMetricsCards(List<Employee> data) {
    final totalHC = data.length;
    final activeHC = data.where((e) => e.isWorking).length;
    final inactiveHC = totalHC - activeHC;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(title: 'Total Headcount', value: totalHC.toString(), color: Colors.blue, isMobile: isMobile),
              _MetricCard(title: 'Active Employees', value: activeHC.toString(), color: Colors.green, isMobile: isMobile),
              _MetricCard(title: 'Inactive / Removed', value: inactiveHC.toString(), color: Colors.redAccent, isMobile: isMobile),
            ],
          );
        }
      ),
    );
  }

  Widget _buildRosterList(List<Employee> data) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Text(
                'Roster Sheet View',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: data.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final emp = data[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: emp.isWorking ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      foregroundColor: emp.isWorking ? Colors.green[800] : Colors.red[800],
                      child: Icon(emp.isWorking ? Icons.person : Icons.person_off),
                    ),
                    title: Text('${emp.name} (${emp.id})'),
                    subtitle: Text('${emp.factoryLocation} • ${emp.department} • ${emp.education}'),
                    trailing: Chip(
                      label: Text(emp.isWorking ? 'Active' : 'Inactive'),
                      backgroundColor: emp.isWorking ? Colors.green[100] : Colors.red[100],
                      labelStyle: TextStyle(
                        color: emp.isWorking ? Colors.green[900] : Colors.red[900],
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _filteredData;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Roster Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricsCards(filteredData),
                _buildRosterList(filteredData),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isMobile;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? double.infinity : 200,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
