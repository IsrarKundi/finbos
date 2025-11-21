class BottomNavController {
  int selectedIndex = 0;
  
  final List<NavItem> navItems = [
    NavItem(
      url: 'https://finbos.app/Dashboard',
      label: 'Dashboard',
      iconData: null, // Will use LineIcons in the UI
    ),
    NavItem(
      url: 'https://finbos.app/Transactions',
      label: 'Transactions',
      iconData: null,
    ),
    NavItem(
      url: 'https://finbos.app/DecisionMaking',
      label: 'AI Assist',
      iconData: null,
    ),
    NavItem(
      url: 'https://finbos.app/Settings',
      label: 'Settings',
      iconData: null,
    ),
  ];

  String getCurrentUrl() {
    return navItems[selectedIndex].url;
  }

  void updateIndex(int index) {
    selectedIndex = index;
  }

  String getUrlByIndex(int index) {
    return navItems[index].url;
  }
}

class NavItem {
  final String url;
  final String label;
  final dynamic iconData;

  NavItem({
    required this.url,
    required this.label,
    this.iconData,
  });
}
