import '../z_entity/base_response.dart';
import '../http/api_client.dart';
import '../http/api_endpoints.dart';

/// 添加/编辑商品
/// [spuData] 商品数据，结构如下：
/// {
///   "spuId": "编辑时传，新增不传",
///   "name": "商品名称",
///   "description": "商品简介",
///   "spuBcId": "经营类目id",
///   "freightModelId": "运费模板id",
///   "showPrice": "吊牌价",
///   "spuServer": [1, 2, ...],  // 服务id列表: 1=保证正品 2=24h发货 3=48h发货 4=7天无理由 5=不支持7天无理由
///   "imageList": [{"image": "url", "width": 0, "height": 0}],  // 主图列表
///   "detailImageList": [{"image": "url", "width": 0, "height": 0}],  // 详情图列表
///   "parameterList": [{"name": "参数名", "description": "参数描述"}],  // 商品参数
///   "skuAttributeDto": {
///     "getFirstAttribute": [{"name": "颜色", "value": "红色"}, ...],
///     "getSecondAttribute": [{"name": "尺码", "value": "S"}, ...],
///     "getThirdAttribute": [{"name": "材质", "value": "棉"}, ...],
///     "skuDtoList": [
///       {"price": "99.00", "stockCount": 100, "limitCount": 5, "image": "sku图片url"},
///       ...
///     ]
///   }
/// }
Future<BaseResponse<void>> postSpuAddUpdate({
  required Map<String, dynamic> spuData,
}) {
  return ApiClient().post(
    ApiEndpoints.spuAddUpdate,
    data: {
      "spuData": spuData,
    },
    fromJsonT: (json) {},
  );
}
