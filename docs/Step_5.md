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
* `Application Load Balancer` の `Create` ボタンをクリック
  * <img src="./assets/step5_lb_create_02.png" width="800px">
* `Load balancer name` に `aws-hands-on` と入力する
  * <img src="./assets/step5_lb_create_03.png" width="800px">
* `Network mapping` の `Mapping` では全て（3つ）のチェックボックスにチェックする 
  * <img src="./assets/step5_lb_create_04.png" width="800px">
* `Security groups` の項目で、`Create new security group` リンクをクリックする
  * <img src="./assets/step5_lb_create_05.png" width="800px">
  * 別タブが開くはず
* セキュリティグループを作成する
  * <img src="./assets/step5_lb_create_06.png" width="800px">

    * セキュリティグループ名: `aws-hands-on`
    * 説明: `aws-hands-on`
    * インバウンドルール
        |  タイプ        |  プロトコル  | ポート範囲 | ソース           | 説明 |
        | ------------- | ---------- | --------- | -------------- | --- |
        |  HTTP         | TCP        | 80       |カスタム 0.0.0.0/0 |　 |
  * `セキュリティグループを作成` ボタンを押す
* 元のタブに戻って、作成したセキュリティグループを選択する
  * <img src="./assets/step5_lb_create_07.png" width="800px">

  * `default` のセキュリティグループは使用しないので `×` を押して削除しておく
* `Listeners and routing` の項目で `Create target group` リンクをクリックする
  * <img src="./assets/step5_lb_create_08.png" width="800px">
  * 別タブが開くはず
* ターゲットグループを作成する
  * <img src="./assets/step5_lb_create_09.png" width="800px">

    * Choose a target type: Instances（デフォルト）
    * Target group name: `aws-hands-on`
    * Protocol: HTTP（デフォルト）
    * Port: 80（デフォルト）
  * <img src="./assets/step5_lb_create_10.png" width="800px">

    * Health check protocol: HTTP（デフォルト）
    * Health check path: `/healthcheck`
    * Port: `Override`, `8000`
  * `Next` ボタンを押す
  * EC2インスタンスをターゲットグループに登録する
  * <img src="./assets/step5_lb_create_11.png" width="800px">
  
    * チェックボックスをチェックし `Includes as pending bellow` ボタンを押す
    * `Create target group` ボタンを押す
* 元のタブに戻って、作成したターゲットグループを選択する
  * <img src="./assets/step5_lb_create_12.png" width="800px">
* `Create load balancer` ボタンを押す
* `View load balancer` ボタンを押す

# ターゲットグループの確認
* `aws-hands-on` のターゲットグループをクリック
  * https://ap-northeast-1.console.aws.amazon.com/ec2/home?region=ap-northeast-1#TargetGroups:
* ターゲットグループには EC2 インスタンスを所属させるが、所属している EC2 インスタンスが健康な状態か（healty）かどうかをチェックしている
  * 健康状態は、httpリクエストに対してレスポンスを返しているかという観点で観測している
* ターゲット（EC2 インスタンス）が健康である場合、 `healty` と判断され、ロードバランサにきたリクエストがそのターゲットに流れるようになる
  * <img src="./assets/step5_lb_target_group_01.png" width="800px">

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
