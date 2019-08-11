//
//  ViewController.swift
//  CardSwipeApp
//
//  Created by 坂口卓也 on 2019/08/10.
//  Copyright © 2019 坂口卓也. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // ここを追加
    @IBOutlet weak var baseCard: UIView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var person1: UIView!
    @IBOutlet weak var person2: UIView!
    @IBOutlet weak var person3: UIView!
    @IBOutlet weak var person4: UIView!
    @IBOutlet weak var person5: UIView!
    
    // カードの中心
    var centerOfCard: CGPoint!
    // ユーザーカードの配列
    var personList: [UIView] = []
    // 選択されたカードの数を数える変数
    var selectedCardCount: Int = 0
    // 各自の名前の配列
    let nameList: [String] = ["津田梅子","ジョージワシントン","ガリレオガリレイ","板垣退助","ジョン万次郎"]
    // 「いいね」をされた名前の配列
    var likedName: [String] = []
    
    // ViewControllerのviewがロードされた後に呼び出される
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // ベースカードの中心を代入
        centerOfCard = baseCard.center
        // personListにperson1から5を追加
        personList.append(person1)
        personList.append(person2)
        personList.append(person3)
        personList.append(person4)
        personList.append(person5)
    }
    
    // viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ユーザーカードを元の位置に戻す
        resetPersonList()
        // カウント初期化
        selectedCardCount = 0
        // リスト初期化
        likedName = []
    }
    
    // viewのレイアウト処理が完了した時に呼ばれる
    override func viewDidLayoutSubviews() {
        // ベースカードの中心を代入
        centerOfCard = baseCard.center
    }
    
    // 完全に遷移が行われ、スクリーン上からViewControllerが表示されなくなったときに呼ばれる
    override func viewDidDisappear(_ animated: Bool) {
        // ユーザーカードを元に戻す
        resetPersonList()
    }
    
    //値の受け渡しの準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToLikedList" {
            let vc = segue.destination as! LikedListTableViewController
            // LikedListTableViewControllerのlikedName(左)にViewCountrollewのLikedName(右)を代入
            vc.likedName = likedName
        }
    }
    
    //カードの位置と角度をリセット
    func resetCard() {
        baseCard.center = centerOfCard
        baseCard.transform = .identity
    }
    
    //カードを元に戻す
    func resetPersonList() {
        // 5人の飛んで行ったビューを元の位置に戻す
        for person in personList {
            // 元に戻す処理
            person.center = self.centerOfCard
            person.transform = .identity
        }
    }
    
    @IBAction func swipeCard(_ sender: UIPanGestureRecognizer) {
        //sender.viewでPanGestureRecognizerでスワイプ動作を検知する対象のview（ここではベースカード）を取得可能。それを定数に代入。
        let card = sender.view!
        // .translation(in: view)でsenderのオブジェクトがviewから動いた距離を取得
        let point = sender.translation(in: view)
        // 取得できた距離をcard.centerに加算
        card.center = CGPoint(x: card.center.x + point.x, y: card.center.y + point.y)
        // ユーザーカードにも同じ動きをさせる
        personList[selectedCardCount].center = CGPoint(x: card.center.x + point.x, y:card.center.y + point.y)
        // 元々の位置と移動先との差
        let xfromCenter = card.center.x - view.center.x
        // 角度(回転しながら飛んでいく)をつける処理
        card.transform = CGAffineTransform(rotationAngle: xfromCenter / (view.frame.width / 2) * -0.785)
        personList[selectedCardCount].transform = CGAffineTransform(rotationAngle: xfromCenter / (view.frame.width / 2) * -0.785)
        
        // likeImageの表示制御
        if xfromCenter > 0 {
            // goodボタンの表示
            likeImage.image = #imageLiteral(resourceName: "いいね")
            likeImage.isHidden = false
        } else if xfromCenter < 0 {
            // badボタンの表示
            likeImage.image = #imageLiteral(resourceName: "よくないね")
            likeImage.isHidden = false
        }
        // 指を離した場合の元の位置に戻す処理
        if sender.state == UIGestureRecognizer.State.ended {
            // 離した時点のカードの中心の位置が左から30以内のとき
            if card.center.x < 30 {
                // 左に大きくスワイプしたときの処理
                UIView.animate(withDuration: 0.5, animations: {
                    // ベースカードの位置と角度を元に戻す
                    self.resetCard()
                    // 該当のユーザーカードを画面外(マイナス方向)へ飛ばす
                    self.personList[self.selectedCardCount].center = CGPoint(x:self.personList[self.selectedCardCount].center.x - 500, y: self.personList[self.selectedCardCount].center.y)
                })
                // likeImageを隠す
                likeImage.isHidden = true
                //次のカードへ
                selectedCardCount += 1
                // 画面遷移
                if selectedCardCount >= personList.count {
                    performSegue(withIdentifier: "ToLikedList", sender: self)
                }
                // 離した時点のカードの中心の位置が右から30以内のとき
            } else if card.center.x > self.view.frame.width - 30 {
                // 右に大きくスワイプしたときの処理
                UIView.animate(withDuration: 0.5, animations: {
                    // ベースカードの位置と角度を元に戻す
                    self.resetCard()
                    // 該当のユーザーカードを画面外(プラス方向)へ飛ばす
                    self.personList[self.selectedCardCount].center = CGPoint(x:self.personList[self.selectedCardCount].center.x + 500, y: self.personList[self.selectedCardCount].center.y)
                })
                // likeImageを隠す
                likeImage.isHidden = true
                //いいねされたリストへ追加
                likedName.append(nameList[selectedCardCount])
                //次のカードへ
                selectedCardCount += 1
                // 画面遷移
                if selectedCardCount >= personList.count {
                    performSegue(withIdentifier: "ToLikedList", sender: self)
                }
            } else {
                // クロージャによるアニメーションの追加
                UIView.animate(withDuration: 0.5, animations: {
                    // ベースカードの位置と角度を元に戻す
                    self.resetCard()
                    // ユーザーカードを元の位置に戻す
                    self.personList[self.selectedCardCount].center = self.centerOfCard
                    // ユーザーカードの角度を元の位置に戻す
                    self.personList[self.selectedCardCount].transform = .identity
                })
                // likeImageを隠す
                likeImage.isHidden = true
            }
        }
    }
    
    //いいね、よくないねボタンが押された場合の処理
    @IBAction func likeButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.resetCard()
            self.personList[self.selectedCardCount].center = CGPoint(x:self.personList[self.selectedCardCount].center.x + 500, y:self.personList[self.selectedCardCount].center.y)
        })
        likeImage.isHidden = true
        likedName.append(nameList[selectedCardCount])
        selectedCardCount += 1
        if selectedCardCount >= personList.count {
            // 画面遷移
            performSegue(withIdentifier: "ToLikedList", sender: self)
        }
        return
    }
    
    
    @IBAction func dislikeButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.resetCard()
            self.personList[self.selectedCardCount].center = CGPoint(x:self.personList[self.selectedCardCount].center.x - 500, y:self.personList[self.selectedCardCount].center.y)
        })
        likeImage.isHidden = true
        selectedCardCount += 1
        if selectedCardCount >= personList.count {
            performSegue(withIdentifier: "ToLikedList", sender: self)
        }
        return
    }
}

