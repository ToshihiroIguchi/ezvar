#ライブラリ読み込み
library(zoo)
library(vars)

#数値データ以外削除
only.numeric <- function(data){
  del.num <- c()
  for(i in 1:length(data[1, ])){
    if(!is.numeric(data[, i])){
      del.num <- c(del.num, i)
      }
  }
  ret <- data[, -del.num]
  return(ret)
}

#zooクラスに変換して、差分を取る。
as.diff <- function(data){
  ret <- diff((as.zoo(only.numeric(data))))
  return(ret)
}

#AICで次数選択してVAR
var.aic <- function(data, lag.max = 12){
  v.data <- as.diff(data)
  result.select <- VARselect(v.data, lag.max = lag.max)
  result.var <- VAR(v.data, p = result.select$selection[1])
  ret <- list(var = result.var, v.data = v.data, data = data)
  class(ret) <- "ezvar"
  return(ret)
}

#diffを戻す
inv.diff <- function(data){
  #行列作成
  mat1 <- function(n){
    #(1 1 1)
    #(0 1 1)
    #(1 1 1)
    mat.vec <- c()
    for(i in 1: n){
      mat.vec <- c(mat.vec, rep(0, times = i - 1), rep(1, times = n - i + 1))
    }
    mat <- matrix(mat.vec, ncol = n, nrow = n, byrow = TRUE)
    return(mat)
  }
  
  #matrixに変換
  mat <- as.matrix(data)
  
  #内席
  inner.product <- function(vec){
    ret <- vec %*% mat1(length(vec))
    return(ret)
  }
  
  ret <- apply(mat, 2, inner.product)
  return(ret)
  
}

#VARで予測した値を出力
var.pred <- function(result, n.ahead = 10){
  if(class(result) != "ezvar"){return(NA)}
  pred.diff <- predict(result$var, n.ahead = n.ahead)
  
  ncol <- length(pred.diff$fcst)
  nrow <- length(pred.diff$fcst[[1]][, 1])
  
  ret.df <- data.frame(
    matrix(rep(NA, times = ncol * nrow), 
           nrow = nrow, ncol = ncol))
  
  names(ret.df) <- names(result$v.data)
  
  for(i in 1:ncol){
    fcst.vec <- pred.diff$fcst[[i]][, 1]
    ret.df[, i] <- fcst.vec
  }
  
  #元のデータの最後の値
  last.val <- only.numeric(result$data)[length(result$data[, 1]),]
  last.val <- as.vector(as.matrix(last.val))
  
  #diffを戻して返す。
  inv.diff.mat <- inv.diff(ret.df)
  
  #last.valを伸ばす
  last.val.mat <- t((last.val) * matrix(1, nrow = length(last.val), ncol = n.ahead))
  
  #データフレームを戻す
  ret <- as.data.frame(inv.diff.mat + last.val.mat)
  return(ret)
}

#data.frameからでもvectorに
as.vector2 <- function(x){as.vector(as.matrix(x))}

#過去の値と予測の値を図示
plot.trend <- function(data =NULL, pred = NULL, name = NULL){
  #エラーチェック
  if(is.null(data) || is.null(pred) || is.null(name)){return(NA)}
  
  #データの長さチェック
  t.data <- length(data[, 1])
  t.pred <- length(pred[, 1])
  
  #予測値をベクトルに
  data.vec <- as.vector2(data[name])
  pred.vec <- as.vector2(pred[name])

  #実測値の最後を加える
  pred2.vec <- c(data.vec[t.data], pred.vec)
  
  #過去の値と予測値をプロット
  plot(c(1:t.data), data.vec, 
       xlim = c(0, t.data + t.pred + 1), type = "l",
       xlab = "t", ylab = name)
  lines(c(t.data:(t.data + t.pred)), pred2.vec, col = 2)
}

#サマリ
summary.ezvar <- function(result){summary(result$var)}


