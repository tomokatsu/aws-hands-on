# Step 5: ロードバランサーを利用してみよう
* 今は直接 EC2 インスタンスで http リクエストを受けているが、前段にアプリケーションロードバランサーを設置する
* アプリケーションロードバランサーとは
  * https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/introduction.html

# アプリケーションロードバランサーと EC2 インスタンスの構成
```
クライアント -- <http:80> -> アプリケーションロードバランサー(HTTP:80 リスナー)
 -> ターゲットグループ -- <http:8000> ->　EC2 インスタンス
```

# ロードバランサーの作成
* `ロードバランサーの作成` ボタンをクリック
  * https://ap-northeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#LoadBalancers:sort=loadBalancerName
  * <img src="./assets/step5_lb_create_01.png" width="800px">
* `Application Load Balancer` の `作成` ボタンをクリック
  * <img src="./assets/step5_lb_create_02.png" width="800px">
* ロードバランサーの名前を設定し、アベイラビリティーゾーンを3つ選択してください
  * <img src="./assets/step5_lb_create_03.png" width="800px">
  * `次の手順: セキュリティ設定の構成` ボタンをクリック
* セキュリティ設定の構成では特に何もせず `次の手順: セキュリティグループの設定` をクリック
* ALB 用のセキュリティグループを作成する
  * <img src="./assets/step5_lb_create_04.png" width="800px">
  * `次の手順: ルーティングの設定` ボタンをクリック
* ターゲットグループを以下のように作成する
  * <img src="./assets/step5_lb_create_05.png" width="800px">
  * `次の手順: ターゲットの登録` ボタンをクリック
* インスタンスを選択し `登録済に追加` ボタンをクリック
  * <img src="./assets/step5_lb_create_06.png" width="800px">
  * <img src="./assets/step5_lb_create_07.png" width="800px">
  * `次の手順: 確認` ボタンをクリック
* 設定内容を確認し`作成`ボタンをクリック

# ターゲットグループの確認
* `aws-hands-on` のターゲットグループをクリック
  * https://ap-northeast-1.console.aws.amazon.com/ec2/home?region=ap-northeast-1#TargetGroups:
  * <img src="./assets/step5_lb_target_group_01.png" width="800px">
* ターゲットグループには EC2 インスタンスを所属させるが、所属している EC2 インスタンスが健康な状態か（healty）かどうかをチェックしている
  * 健康状態は、httpリクエストに対してレスポンスを返しているかという観点で観測している
    * <img src="./assets/step5_lb_target_group_02.png" width="800px">
* ターゲット（EC2 インスタンス）が健康である場合、 `healty` と判断され、ロードバランサにきたリクエストがそのターゲットに流れるようになる
  * <img src="./assets/step5_lb_target_group_03.png" width="800px">

# ロードバランサーの確認
* リスナータブでは、80番ポートに来たHTTPプロトコルのリクエストを、どういうルールでターゲットに流すかという設定がされている
  * https://ap-northeast-1.console.aws.amazon.com/ec2/home?region=ap-northeast-1#LoadBalancers:sort=loadBalancerName
  * `ルール`の項目にある `転送先`（aws-hands-on） はターゲットグループ
  * <img src="./assets/step5_lb_load_balancer_01.png" width="800px">
* 説明タブにある `DNS名` を使って、ブラウザからアクセスしてみると、Django のページが見れるはず
  * <img src="./assets/step5_lb_load_balancer_02.png" width="800px">

# EC2 インスタンスのセキュリティーグループを制限しよう
* ロードバランサからアクセスできるようになったので、EC2 インスタンスに直接アクセスする必要はありません
* 不用意にポートを開けておくのはセキュリティーリスクにもつながるので、適切に制限しましょう
* `aws-hands-on-ec2` のセキュリティーグループを選択
  * https://ap-northeast-1.console.aws.amazon.com/ec2/home?region=ap-northeast-1#SecurityGroups:
  * <img src="./assets/step5_security_group_01.png" width="800px">
* `インバウンドルールを編集` ボタンをクリック
  * <img src="./assets/step5_security_group_02.png" width="800px">
* `インバウンドルール` を以下のように設定
  * <img src="./assets/step5_security_group_03.png" width="800px">
  * `8000` ポートに届くリクエストのソースに `アプリケーションロードバランサーのセキュリティーグループ（aws-hands-on-alb）`を選択
  * `ルールの保存` ボタンをクリック
* 保存されたインバウンドルールはこのようになるはず
  * <img src="./assets/step5_security_group_04.png" width="800px">
* これでアプリケーションロードバランサーへの 80 番ポートに対するリクエストのみが EC2 インスタンスに到達するようになった
