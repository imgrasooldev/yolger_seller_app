class CampaignProductsResponse {
  bool? success;
  String? message;
  CampaignProductData? data;

  CampaignProductsResponse({this.success, this.message, this.data});

  CampaignProductsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? CampaignProductData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CampaignProductData {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  List<CampaignProduct>? data;

  CampaignProductData({this.currentPage, this.lastPage, this.perPage, this.total, this.data});

  CampaignProductData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
    if (json['data'] != null) {
      data = <CampaignProduct>[];
      json['data'].forEach((v) {
        data!.add(new CampaignProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CampaignProduct {
  int? id;
  String? uuid;
  int? categoryId;
  int? brandId;
  int? sellerId;
  String? title;
  String? slug;
  String? type;
  String? shortDescription;
  String? category;
  String? brand;
  String? categoryName;
  String? brandName;
  String? seller;
  String? indicator;
  String? favorite;
  String? estimatedDeliveryTime;
  int? basePrepTime;
  String? ratings;
  int? ratingCount;
  String? mainImage;
  String? imageFit;
  bool? isSaveForLater;
  List<String>? additionalImages;
  int? minimumOrderQuantity;
  int? quantityStepSize;
  int? totalAllowedQuantity;
  int? isReturnable;
  int? isAttachmentRequired;
  String? attachmentMode;
  int? requiresOtp;
  String? warrantyPeriod;
  String? guaranteePeriod;
  String? madeIn;
  String? isInclusiveTax;
  String? videoType;
  String? videoLink;
  String? status;
  Metadata? metadata;
  String? createdAt;
  String? updatedAt;
  bool? isSponsored;
  String? campaignId;
  String? visitorKey;

  CampaignProduct(
      {this.id,
        this.uuid,
        this.categoryId,
        this.brandId,
        this.sellerId,
        this.title,
        this.slug,
        this.type,
        this.shortDescription,
        this.category,
        this.brand,
        this.categoryName,
        this.brandName,
        this.seller,
        this.indicator,
        this.favorite,
        this.estimatedDeliveryTime,
        this.basePrepTime,
        this.ratings,
        this.ratingCount,
        this.mainImage,
        this.imageFit,
        this.isSaveForLater,
        this.additionalImages,
        this.minimumOrderQuantity,
        this.quantityStepSize,
        this.totalAllowedQuantity,
        this.isReturnable,
        this.isAttachmentRequired,
        this.attachmentMode,
        this.requiresOtp,
        this.warrantyPeriod,
        this.guaranteePeriod,
        this.madeIn,
        this.isInclusiveTax,
        this.videoType,
        this.videoLink,
        this.status,
        this.metadata,
        this.createdAt,
        this.updatedAt,
        this.isSponsored,
        this.campaignId,
        this.visitorKey});

  CampaignProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    categoryId = json['category_id'];
    brandId = json['brand_id'];
    sellerId = json['seller_id'];
    title = json['title'];
    slug = json['slug'];
    type = json['type'];
    shortDescription = json['short_description'];
    category = json['category'];
    brand = json['brand'];
    categoryName = json['category_name'];
    brandName = json['brand_name'];
    seller = json['seller'];
    indicator = json['indicator'];
    favorite = json['favorite'];
    estimatedDeliveryTime = json['estimated_delivery_time'];
    basePrepTime = json['base_prep_time'];
    ratings = json['ratings'].toString();
    ratingCount = json['rating_count'];
    mainImage = json['main_image'];
    imageFit = json['image_fit'];
    isSaveForLater = json['is_save_for_later'];
    additionalImages = json['additional_images'].cast<String>();
    minimumOrderQuantity = json['minimum_order_quantity'];
    quantityStepSize = json['quantity_step_size'];
    totalAllowedQuantity = json['total_allowed_quantity'];
    isReturnable = json['is_returnable'];
    isAttachmentRequired = json['is_attachment_required'];
    attachmentMode = json['attachment_mode'];
    requiresOtp = json['requires_otp'];
    warrantyPeriod = json['warranty_period'];
    guaranteePeriod = json['guarantee_period'];
    madeIn = json['made_in'];
    isInclusiveTax = json['is_inclusive_tax'];
    videoType = json['video_type'];
    videoLink = json['video_link'];
    status = json['status'];
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isSponsored = json['is_sponsored'];
    campaignId = json['campaign_id'];
    visitorKey = json['visitor_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['category_id'] = categoryId;
    data['brand_id'] = brandId;
    data['seller_id'] = sellerId;
    data['title'] = title;
    data['slug'] = slug;
    data['type'] = type;
    data['short_description'] = shortDescription;
    data['category'] = category;
    data['brand'] = brand;
    data['category_name'] = categoryName;
    data['brand_name'] = brandName;
    data['seller'] = seller;
    data['indicator'] = indicator;
    data['favorite'] = favorite;
    data['estimated_delivery_time'] = estimatedDeliveryTime;
    data['base_prep_time'] = basePrepTime;
    data['ratings'] = ratings;
    data['rating_count'] = ratingCount;
    data['main_image'] = mainImage;
    data['image_fit'] = imageFit;
    data['is_save_for_later'] = isSaveForLater;
    data['additional_images'] = additionalImages;
    data['minimum_order_quantity'] = minimumOrderQuantity;
    data['quantity_step_size'] = quantityStepSize;
    data['total_allowed_quantity'] = totalAllowedQuantity;
    data['is_returnable'] = isReturnable;
    data['is_attachment_required'] = isAttachmentRequired;
    data['attachment_mode'] = attachmentMode;
    data['requires_otp'] = requiresOtp;
    data['warranty_period'] = warrantyPeriod;
    data['guarantee_period'] = guaranteePeriod;
    data['made_in'] = madeIn;
    data['is_inclusive_tax'] = isInclusiveTax;
    data['video_type'] = videoType;
    data['video_link'] = videoLink;
    data['status'] = status;
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_sponsored'] = isSponsored;
    data['campaign_id'] = campaignId;
    data['visitor_key'] = visitorKey;
    return data;
  }
}

class Metadata {
  String? seoTitle;
  List<String>? seoKeywords;
  String? seoDescription;

  Metadata({this.seoTitle, this.seoKeywords, this.seoDescription});

  Metadata.fromJson(Map<String, dynamic> json) {
    seoTitle = json['seo_title'];
    seoKeywords = json['seo_keywords'].cast<String>();
    seoDescription = json['seo_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seo_title'] = seoTitle;
    data['seo_keywords'] = seoKeywords;
    data['seo_description'] = seoDescription;
    return data;
  }
}

class StoreStatus {
  bool? isOpen;
  String? status;

  StoreStatus({this.isOpen, this.status});

  StoreStatus.fromJson(Map<String, dynamic> json) {
    isOpen = json['is_open'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_open'] = isOpen;
    data['status'] = status;
    return data;
  }
}

