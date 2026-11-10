"""연습용 합성 데이터를 만든다. 실제 공정 데이터가 아니다.

  python3 make_data.py [출력 폴더, 기본 ./data]

A_small_n.csv   회귀. 58행(Y 가 있는 47행 + Y 가 빈 제출 대상 11행), 변수 36개(뒤 4개는 코드형 범주). 학습 구간에 완전히 같은 행 1개.
B_imbalance.csv 분류. 1567행(라벨 있는 1367행 + 라벨이 빈 제출 대상 200행), 센서 474개, 불량(+1) 약 6%.
                서로 상관이 큰 센서 묶음, 상수 열, 완전히 같은 열 묶음이 섞여 있다.
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

rng = np.random.default_rng(7)
out = Path(sys.argv[1] if len(sys.argv) > 1 else "data")
out.mkdir(parents=True, exist_ok=True)

# A: small n 회귀
n, p_num = 58, 32
X = rng.normal(size=(n, p_num))
cats = rng.integers(1, 4, size=(n, 4))                      # X33~X36: 1~3 코드
y = (0.6 * X[:, 0] - 0.4 * X[:, 3] + 0.3 * X[:, 7] * X[:, 8]
     + 0.25 * (cats[:, 0] == 2) + rng.normal(scale=0.3, size=n))
A = pd.DataFrame(np.column_stack([X, cats]), columns=[f"X{i}" for i in range(1, 37)])
A[[f"X{i}" for i in range(33, 37)]] = A[[f"X{i}" for i in range(33, 37)]].astype(int)
A["Y"] = (y - y.min()) / (y.max() - y.min())                 # 0~1 로 맞춤
A.loc[47:, "Y"] = np.nan                                     # 제출 대상
A.iloc[5, :36] = A.iloc[4, :36]; A.loc[5, "Y"] = A.loc[4, "Y"]  # 학습 구간의 완전 중복 1행
A.to_csv(out / "A_small_n.csv", index=False)

# B: 고차원 + 불균형 분류
n, p = 1567, 474
blocks = rng.normal(size=(n, 40))                            # 잠재 요인 40개 → 센서들이 묶음으로 상관
load = rng.normal(scale=0.8, size=(40, p)) * (rng.random((40, p)) < 0.08)
S = blocks @ load + rng.normal(scale=0.5, size=(n, p))
risk = 1.2 * blocks[:, 0] - 0.9 * blocks[:, 5] + 0.7 * np.abs(blocks[:, 11]) + rng.normal(scale=0.8, size=n)
yb = np.where(risk > np.quantile(risk, 0.94), 1, -1)
S[:, 10] = 3.0                                               # 상수 열
for j in range(101, 106):                                    # X101~X106 이 완전히 같은 열 묶음
    S[:, j] = S[:, 100]
B = pd.DataFrame(S.round(4), columns=[f"X{i}" for i in range(1, p + 1)])
B["Y"] = yb.astype(float)
B.loc[1367:, "Y"] = np.nan                                   # 제출 대상
B.to_csv(out / "B_imbalance.csv", index=False)

lab = B["Y"].dropna()
print(f"A_small_n.csv   {A.shape}, 학습 {A['Y'].notna().sum()}행")
print(f"B_imbalance.csv {B.shape}, 학습 {len(lab)}행, 불량 {int((lab == 1).sum())} / 정상 {int((lab == -1).sum())}")
