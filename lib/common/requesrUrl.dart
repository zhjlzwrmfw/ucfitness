class RequestUrl {
  ///用户信息操作请求Url
  static const String downLoadPictureUrl = 'https://www.ucfitness.club/api/picture/path/'; //下载图片
  static const String checkBindMailUrl = 'https://www.ucfitness.club/api/public/isExist/mail'; //是否绑定邮箱
  static const String checkBindPhoneUrl = 'https://www.ucfitness.club/api/public/isExist/phone'; //是否绑定手机号
  static const String pwdLoginUrl = 'https://www.ucfitness.club/api/public/login/pwd'; //密码登录Url
  static const String mailLoginUrl = 'https://www.ucfitness.club/api/public/login/verCode/mail'; //邮箱登录Url
  static const String phoneLoginUrl = 'https://www.ucfitness.club/api/public/login/verCode/phone'; //邮箱登录Url
  static const String updatePwdUrl = 'https://www.ucfitness.club/api/public/password'; //修改密码
  static const String checkNumberUrl = 'https://www.ucfitness.club/api/public/verCode/check'; //验证码验证是否正确
  static const String sendMailNumberUrl = 'https://www.ucfitness.club/api/public/verCode/mail'; //向邮箱发送验证码
  static const String sendPhoneNumberUrl = 'https://www.ucfitness.club/api/public/verCode/phone'; //向手机发送验证码
  static const String updatePictureUrl = 'https://www.ucfitness.club/api/user/headImg'; //修改用户头像
  static const String getUserInfoUrl = 'https://www.ucfitness.club/api/user/info'; //获取和修改用户信息
  static const String deleteUserInfoUrl = 'https://www.ucfitness.club/api/user/loginOut'; //注销账号
  static const String updateMailUrl = 'https://www.ucfitness.club/api/user/mail'; //修改邮箱
  static const String updatePhoneUrl = 'https://www.ucfitness.club/api/user/phoneNumber'; //修改手机
  static const String signOutUrl = 'https://www.ucfitness.club/api/user/signOut'; //退出登录
  static const String refreshTokenUrl = 'https://www.ucfitness.club/api/public/refreshToken'; //刷新token
  static const String getUserPictureUrl = 'https://www.ucfitness.club/api/picture/thumbnails/?hash='; //排行榜用户头像

  ///ota
  static const String otaTergasyVersionUrl = 'https://cloud.capstong.com:8083/ota/deviceVersion/'; //五件套ota版本号
  static const String otaTergasyFileUrl = 'https://cloud.capstong.com:8083/ota/file/'; //五件套ota文件
  static const String appPass = 'Chuan1212';

  ///运动数据操作请求Url
  static const String historySportDataUrl = 'https://www.ucfitness.club/api/sport/data/history'; //查询、上传、删除运动数据
  static const String getSportDataUrl = 'https://www.ucfitness.club/api/sport/data/history/detail'; //获取详细运动数据
  static const String getStatisticsUrl = 'https://www.ucfitness.club/api/sport/statistics'; //获取特定时间数据
  static const String getStatisticsSpecialUrl = 'https://www.ucfitness.club/api/sport/statistics/specialTime'; //获取某个时间段的数据
  static const String getTotalAbilityUrl = 'https://www.ucfitness.club/api/sport/statistics/ability'; //获取用户总的战斗力以及排名信息
  static const String getMonthAbilityUrl = 'https://www.ucfitness.club/api/sport/statistics/ability/month'; //获取用户月战斗力以及排名信息
  static const String getYearAbilityUrl = 'https://www.ucfitness.club/api/sport/statistics/ability/year'; //获取用户年战斗力以及排名信息
  static const String getTotalAbilityRankUrl = 'https://www.ucfitness.club/api/sport/statistics/leaderboard'; //获取总战斗力排行榜
  static const String getMonthAbilityRankUrl = 'https://www.ucfitness.club/api/sport/statistics/leaderboard/month'; //获取月战斗力排行榜
  static const String getYearAbilityRankUrl = 'https://www.ucfitness.club/api/sport/statistics/leaderboard/year'; //获取年战斗力排行榜

///课程训练请求Url
  static const String getCourseListUrl = 'https://www.ucfitness.club:443/api/course/list';//获取课程列表
  static const String getCollectCourseListUrl = 'https://www.ucfitness.club:443/api/course/collect';//获取收藏课程列表
  static const String courseCollectUrl = 'https://www.ucfitness.club:443/api/course/collect';//收藏取消课程
  static const String downVideoUrl = 'https://www.ucfitness.club:443/api/video/';//下载课程视频
  static const String downVoiceUrl = 'https://www.ucfitness.club:443/api/voice/';//下载课程音频
  static const String getCourseAction = 'https://www.ucfitness.club:443/api/course/actions';//下载课程音频

///勋章请求Url
  static const String getMedalGroupUrl = 'https://www.ucfitness.club:443/api/sport/statistics/user/medal/group';//获取某个组的勋章信息
  static const String getMedalPanelUrl = 'https://www.ucfitness.club:443/api/sport/statistics/user/medal/panel';//获取用户的勋章面板
  static const String getMedalNewUrl = 'https://www.ucfitness.club:443/api/sport/statistics/user/medal/new';//获取用户的新勋章信息
  static const String putMedalReadUrl = 'https://www.ucfitness.club:443/api/sport/statistics/user/medal/read';//将勋章修改为已读
  static const String getMedalTotalCountUrl = 'https://www.ucfitness.club:443/api/sport/statistics/user/medal/totalCount';//获得的全部勋章
}