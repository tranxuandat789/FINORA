import 'package:flutter/material.dart';

class GoalIconMapper {
  static const Map<String, IconData> _icons = {
    'beach_access': Icons.beach_access,
    'flight': Icons.flight,
    'home': Icons.home,
    'school': Icons.school,
    'savings': Icons.savings,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'restaurant': Icons.restaurant,
    'monitor': Icons.monitor,
    'favorite': Icons.favorite,
    'fitness_center': Icons.fitness_center,
    'motorcycle': Icons.motorcycle,
    'laptop': Icons.laptop,
    'phone_iphone': Icons.phone_iphone,
    'chair': Icons.chair,
  };

  static IconData getIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) return Icons.star;
    return _icons[iconName] ?? Icons.star;
  }

  static List<String> get availableIconNames => _icons.keys.toList();

  static bool isUrl(String? iconName) {
    if (iconName == null) return false;
    return iconName.startsWith('http://') || iconName.startsWith('https://');
  }

  static Widget buildGoalIcon(String? iconName, {double size = 24, Color color = Colors.black}) {
    if (isUrl(iconName)) {
      return ClipOval(
        child: Image.network(
          iconName!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: size, color: color),
        ),
      );
    }
    return Icon(getIcon(iconName), size: size, color: color);
  }
}
