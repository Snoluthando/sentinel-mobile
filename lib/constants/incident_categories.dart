import 'package:flutter/material.dart';

class IncidentCategoryItem {
  const IncidentCategoryItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
}

const List<IncidentCategoryItem> kIncidentCategories = [
  IncidentCategoryItem(id: 'robbery', label: 'Robbery', icon: Icons.gpp_bad, color: Color(0xFFEF4444)),
  IncidentCategoryItem(id: 'theft', label: 'Theft', icon: Icons.shopping_bag_outlined, color: Color(0xFFF97316)),
  IncidentCategoryItem(id: 'burglary', label: 'Burglary', icon: Icons.home_outlined, color: Color(0xFFEAB308)),
  IncidentCategoryItem(id: 'vehicle_theft', label: 'Vehicle Theft', icon: Icons.directions_car_outlined, color: Color(0xFF8B5CF6)),
  IncidentCategoryItem(id: 'assault', label: 'Assault', icon: Icons.warning_amber, color: Color(0xFFDC2626)),
  IncidentCategoryItem(id: 'suspicious_activity', label: 'Suspicious', icon: Icons.visibility_outlined, color: Color(0xFF3B82F6)),
  IncidentCategoryItem(id: 'vandalism', label: 'Vandalism', icon: Icons.build_outlined, color: Color(0xFF6B7280)),
  IncidentCategoryItem(id: 'drug_activity', label: 'Drug Activity', icon: Icons.medical_services_outlined, color: Color(0xFF10B981)),
  IncidentCategoryItem(id: 'road_accident', label: 'Road Accident', icon: Icons.local_hospital_outlined, color: Color(0xFF64748B)),
  IncidentCategoryItem(id: 'other', label: 'Other', icon: Icons.description_outlined, color: Color(0xFF94A3B8)),
];

IncidentCategoryItem categoryForId(String id) {
  return kIncidentCategories.firstWhere(
    (c) => c.id == id,
    orElse: () => kIncidentCategories.last,
  );
}
