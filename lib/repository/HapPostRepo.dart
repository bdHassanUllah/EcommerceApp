// Repositories

import '../apiFiles/BlogsApi.dart';
import '../apiFiles/BusinessApi.dart';
import '../apiFiles/MarketplaceApi.dart';

class MarketplaceRepository {
  final MarketplaceUrl mktApiService;

  MarketplaceRepository(this.mktApiService);

  Future<List<dynamic>> fetchMarketplacePosts() =>
      mktApiService.getData('/marketplaces/');
}

class BlogsRepository {
  final Blogsapi blogsApi;

  BlogsRepository(this.blogsApi);

  Future<List<dynamic>> fetchBlogsPosts() => blogsApi.getBlogsData('/blogs');
}

class BusinessRepository {
  final BusinessApi businessApi;

  BusinessRepository(this.businessApi);

  Future<List<dynamic>> fetchBusinessPosts() =>
      businessApi.getBusinessData('/businesses');
}
