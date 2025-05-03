class MarketplaceItemData {
  final String imagePath; // Or image URL
  final String title;
  final String? subtitle; // Optional subtitle

  MarketplaceItemData({
    required this.imagePath,
    required this.title,
    this.subtitle,
  });
}

// Sample Data - Replace with your actual data from API or database
final List<MarketplaceItemData> marketplaceItems = [
  MarketplaceItemData(imagePath: 'assets/daraz_image.png', title: 'Daraz: The Full Review'), // Replace with your image paths
  MarketplaceItemData(imagePath: 'assets/aliexpress_image.png', title: 'AliExpress: The Full Review'),
  MarketplaceItemData(imagePath: 'assets/olx_image.png', title: 'Olx: The Full Review'),
  MarketplaceItemData(imagePath: 'assets/telemart_image.png', title: 'Telemart: The Full Review'),
  MarketplaceItemData(imagePath: 'assets/pakwheels_image.png', title: 'PakWheels: The Full Review'),
  MarketplaceItemData(imagePath: 'assets/priceoye_image.png', title: 'PriceOye Pakistan: The Full Review'),
];