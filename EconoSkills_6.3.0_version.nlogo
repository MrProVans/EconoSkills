; Определяем породы агентов
breed [companies company]

; Определяем свойства агентов
companies-own [
  field-of-activity    ; Сфера деятельности
  budget               ; Бюджет
  payback-period       ; Период окупаемости
  profit               ; Прибыль/убытки
]

; Определяем глобальные переменные
globals [
  sum_regular_fin      ; Объем общего финансирования
  sum_crisis           ; Объем кризисных ударов
  sum_count_companies  ; Количество компаний на поле
  count_med            ; Количество мед компаний на поле
  count_IT             ; Количество IT компаний на поле
  count_raw            ; Количество компаний сырьевой промышленности
  count_retail         ; Количество компаний розничной торговли
  count_banking        ; Количество банковских компаний
]

; Настройка начального состояния
to setup
  clear-all
  clear-turtles   ; Очищаем всех агентов с поля
  set sum_regular_fin 0
  set sum_crisis 0
  set sum_count_companies 0
  set count_med 0
  set count_IT 0
  set count_raw 0
  set count_retail 0
  set count_banking 0
  reset-ticks
end

; Добавление компаний на поле
to add-companies
  create-companies Count_company [
    setxy random-xcor random-ycor
    set shape "person"                       ; Устанавливаем форму агента "человечек"
    set size 1.5                             ; Размер агента
    set budget init_budget * (0.8 + random-float 0.4)  ; Начальный бюджет с разбросом от 0.8 до 1.2
    set payback-period random payback_period         ; Рандомный период окупаемости
    set profit profit_company                         ; Установка начального значения прибыли/убытков
    set field-of-activity Field_of_activity           ; Установка сферы деятельности
    set color determine-color Field_of_activity       ; Установка цвета в зависимости от сферы деятельности
    update-counters field-of-activity 1               ; Обновление счетчиков компаний по сферам
  ]
end

; Определение цвета компании в зависимости от сферы деятельности
to-report determine-color [field]
  ifelse field = "Medicine" [report pink]
  [ifelse field = "IT" [report blue]
  [ifelse field = "Raw_materials" [report brown]
  [ifelse field = "Retail_trade" [report orange]
  [ifelse field = "Banking" [report red]
  [report black]]]]]
end

; Обновление счетчиков компаний по сферам деятельности
to update-counters [field delta]
  set sum_count_companies sum_count_companies + delta
  if field = "Medicine" [set count_med count_med + delta]
  if field = "IT" [set count_IT count_IT + delta]
  if field = "Raw_materials" [set count_raw count_raw + delta]
  if field = "Retail_trade" [set count_retail count_retail + delta]
  if field = "Banking" [set count_banking count_banking + delta]
end

; Регулярное финансирование компаний
to regular-finance
  if opportunity_reg_fin [
    let total-financing regular_financing * count companies
    if gos_budget >= total-financing [
      ask companies [
        set budget budget + regular_financing
      ]
      set gos_budget gos_budget - total-financing
    ]
  ]
end

; Начальное финансирование компаний
to init-finance
  if opportunity_init_fin [
    let total-financing init_financing * count companies
    if gos_budget >= total-financing [
      ask companies [
        set budget budget + init_financing
      ]
      set gos_budget gos_budget - total-financing
    ]
  ]
end

; Финансирование компаний на грани краха
to sos-finance
  if help_bankroty [
    ask companies with [budget < sos_financing] [
      if gos_budget >= sos_financing [
        set budget budget + sos_financing
        set gos_budget gos_budget - sos_financing
      ]
    ]
  ]
end

; Имитация финансового кризиса
to big-crisis
  ask companies [
    set budget budget - 1000000
  ]
  set sum_crisis sum_crisis + 1000000 * sum_count_companies
end

to medium-crisis
  ask companies [
    set budget budget - 500000
  ]
  set sum_crisis sum_crisis + 500000 * sum_count_companies
end

to easy-crisis
  ask companies [
    set budget budget - 150000
  ]
  set sum_crisis sum_crisis + 150000 * sum_count_companies
end

; Шаг модели
to go
  regular-finance
  sos-finance
  ask companies [
    ; Действия компаний на каждом шаге
    if ticks > payback-period [
      set profit profit + 0.01 * budget  ; Прибыль после окупаемости
      set budget budget + profit
    ]
    if budget < 0 [
      update-counters field-of-activity -1
      die
    ]
    move-company
  ]
  tick
  update-plots  ; Обновление графиков на каждом шаге
end

; Движение компании и отталкивание от стенок
to move-company
  rt random 50 - random 50
  fd 1
  if xcor > max-pxcor or xcor < min-pxcor [ rt 180 ]
  if ycor > max-pycor or ycor < min-pycor [ rt 180 ]
end

; Демонстрация - создание компаний всех сфер и запуск движения
to demo
  setup
  let sectors ["Medicine" "IT" "Raw_materials" "Retail_trade" "Banking"]
  foreach sectors [ sector ->
    set Field_of_activity sector
    create-companies 7 [
      setxy random-xcor random-ycor
      set shape "person"
      set size 1.5
      set budget init_budget * (0.8 + random-float 0.4)
      set payback-period payback_period
      set profit profit_company
      set field-of-activity Field_of_activity
      set color determine-color Field_of_activity
      update-counters field-of-activity 1
    ]
  ]
  go
end

; Шаг модели (один тик)
to go-once
  go
end
@#$#@#$#@
GRAPHICS-WINDOW
860
56
1397
594
-1
-1
16.03030303030303
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

TEXTBOX
558
10
797
44
Жизнь компаний
27
0.0
1

TEXTBOX
7
67
403
89
Государственное финансирование компаний:\n
16
0.0
1

SLIDER
123
103
295
136
gos_budget
gos_budget
0
1000000
973897.5
100
1
NIL
HORIZONTAL

SLIDER
124
151
296
184
regular_financing
regular_financing
0
10
1.5
0.5
1
NIL
HORIZONTAL

TEXTBOX
8
244
117
289
Финансирование компаний на грани краха?
11
0.0
1

SWITCH
305
243
451
276
help_bankroty
help_bankroty
0
1
-1000

TEXTBOX
9
303
306
326
Имитация финансовых кризисов:
16
0.0
1

BUTTON
8
348
98
381
Big_crisis
big-crisis
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
113
348
233
381
Medium_crisis
medium-crisis
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
245
348
345
381
Easy_crisis
easy-crisis
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
18
388
86
406
-1.000.000
11
0.0
1

TEXTBOX
11
325
330
343
Сокращает бюджет компаний на фиксированнное значение
10
0.0
1

TEXTBOX
140
388
194
406
-500.000\n
11
0.0
1

TEXTBOX
265
388
317
406
-150.000\n
11
0.0
1

TEXTBOX
494
97
665
115
Начальный бюджет компаний:
11
0.0
1

TEXTBOX
495
115
645
133
(Среднее значение)\n
10
0.0
1

SLIDER
666
97
838
130
init_budget
init_budget
0
100000
27390.0
10
1
NIL
HORIZONTAL

TEXTBOX
6
105
107
133
Бюджет госфонда поддержки:\n
11
0.0
1

TEXTBOX
6
152
129
194
Регулярное финансирование (%):
11
0.0
1

SWITCH
304
151
485
184
opportunity_reg_fin
opportunity_reg_fin
0
1
-1000

TEXTBOX
6
197
108
225
Начальное финансирование:
11
0.0
1

SLIDER
124
197
296
230
init_financing
init_financing
0
1000
60.0
10
1
NIL
HORIZONTAL

SWITCH
304
196
484
229
opportunity_init_fin
opportunity_init_fin
0
1
-1000

SLIDER
124
244
296
277
sos_financing
sos_financing
0
10000
500.0
100
1
NIL
HORIZONTAL

TEXTBOX
492
65
642
85
Компании:
16
0.0
1

CHOOSER
666
142
804
187
Field_of_activity
Field_of_activity
"Medicine" "IT" "Raw_materials" "Retail_trade" "Banking"
1

TEXTBOX
496
143
612
171
Сфера деятельности компании:
11
0.0
1

TEXTBOX
497
199
624
217
Период окупаемости:\n
11
0.0
1

TEXTBOX
498
214
648
232
(Количество тиков)
10
0.0
1

SLIDER
666
200
838
233
payback_period
payback_period
0
5000
350.0
10
1
NIL
HORIZONTAL

TEXTBOX
498
299
628
317
Количество компаний:
11
0.0
1

SLIDER
666
295
838
328
count_company
count_company
0
100
15.0
1
1
NIL
HORIZONTAL

TEXTBOX
497
245
647
263
Прибыль или убытки:\n
11
0.0
1

TEXTBOX
496
263
648
282
(В зависимости, прошла ли компания период окупаемости)
8
0.0
1

SLIDER
666
249
838
282
profit_company
profit_company
0
500
340.0
10
1
NIL
HORIZONTAL

TEXTBOX
500
346
627
374
Добавить компанию на поле:
11
0.0
1

BUTTON
667
347
795
380
add_companies
add-companies
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1058
612
1124
645
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1297
612
1360
645
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
862
605
1034
642
Базовое управление моделью:
16
0.0
1

TEXTBOX
8
418
413
440
Состояние государственного фонда поддержки:
16
0.0
1

MONITOR
11
445
225
490
Объем общего финанс-ия
sum_regular_fin
17
1
11

MONITOR
224
445
382
490
Объем кризисных ударов
sum_crisis
17
1
11

PLOT
11
492
383
628
Бюджет государственного фонда
ticks
budget
0.0
10.0
0.0
10.0
true
false
"" "plot gos_budget\n"
PENS
"State Budget" 1.0 0 -16777216 true "" "plot gos_budget"

TEXTBOX
458
418
799
440
Состояние жизнидеятельности компаний:
16
0.0
1

PLOT
417
491
839
628
Экономическое состояние типов компаний
ticks
budget
0.0
10.0
0.0
10.0
true
false
"" "set-current-plot-pen \"Medicine\"\nplot sum [budget] of companies with [field-of-activity = \"Medicine\"]\n\nset-current-plot-pen \"IT\"\nplot sum [budget] of companies with [field-of-activity = \"IT\"]\n\nset-current-plot-pen \"Raw_materials\"\nplot sum [budget] of companies with [field-of-activity = \"Raw_materials\"]\n\nset-current-plot-pen \"Retail_trade\"\nplot sum [budget] of companies with [field-of-activity = \"Retail_trade\"]\n\nset-current-plot-pen \"Banking\"\nplot sum [budget] of companies with [field-of-activity = \"Banking\"]\n"
PENS
"\"Medicine\"" 1.0 0 -1664597 true "" "plot sum [budget] of companies with [field-of-activity = \"Medicine\"]"
"\"IT\"" 1.0 0 -13791810 true "" "plot sum [budget] of companies with [field-of-activity = \"IT\"]"
"\"Raw_materials\"" 1.0 0 -6459832 true "" "plot sum [budget] of companies with [field-of-activity = \"Raw_materials\"]"
"\"Retail_trade\"" 1.0 0 -955883 true "" "plot sum [budget] of companies with [field-of-activity = \"Retail_trade\"]"
"\"Banking\"" 1.0 0 -2674135 true "" "plot sum [budget] of companies with [field-of-activity = \"Banking\"]"

MONITOR
417
446
522
491
Всего компаний
sum_count_companies
5
1
11

MONITOR
520
446
591
491
Медицина
count_med
17
1
11

MONITOR
590
446
640
491
IT
count_IT
17
1
11

MONITOR
639
446
713
491
Сырьевая...
count_raw
17
1
11

MONITOR
712
446
790
491
Розничная...
count_retail
17
1
11

MONITOR
788
446
839
491
Банковская
count_banking
17
1
11

BUTTON
1206
612
1291
645
go-once
NIL
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1131
612
1197
645
demo
demo
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## ЧТО ЭТО?

Эта модель демонстрирует динамику жизни компаний в различных секторах экономики, таких как медицина, IT, сырьевая промышленность, розничная торговля и банковская сфера. Модель исследует влияние государственного финансирования и кризисов на бюджет и выживаемость компаний, а также их способность достигать окупаемости и слияния.

## КАК ЭТО РАБОТАЕТ

Агенты компании имеют следующие атрибуты: сфера деятельности, цвет, бюджет, период окупаемости и государственное финансирование. Государство выделяет регулярное финансирование компаниям и проводит начальные инвестиции. Компании могут объединяться (слияние) и в случае достижения окупаемости возвращают 1% от бюджета в фонд поддержки. Во время кризисов компании теряют определенное количество средств в зависимости от масштаба кризиса (большой, средний, малый).

## КАК ИСПОЛЬЗОВАТЬ

- Глобальные переменные:
  - Количество компаний в каждой сфере.
  - Бюджет фонда поддержки.

- Ползунки:
  - Фонд поддержки государства:
    - Финансовые ресурсы (фонд поддержки).
    - Регулярное финансирование из фонда поддержки.
    - Финансируем ли компании на грани краха (булевый ползунок).

  - Кризисы:
    - Big crisis (-1.000.000).
    - Medium crisis (-500.000).
    - Easy crisis (-150.000).

  - Начальный бюджет компаний:
    - Средний бюджет компаний при создании.

## ЧТО ЗАМЕТИТЬ

Обратите внимание на то, как компании различных сфер деятельности реагируют на государственное финансирование и кризисы. Следите за тем, как бюджет компаний изменяется со временем и как это влияет на их способность достигать окупаемости и слияния.

## ЧТО ПОПРОБОВАТЬ

- Измените размер фонда поддержки государства и наблюдайте, как это влияет на выживаемость компаний.
- Включите или отключите финансирование компаний на грани краха и посмотрите на результаты.
- Инициируйте кризисы разных масштабов и наблюдайте, как компании реагируют на эти события.

## РАСШИРЕНИЕ МОДЕЛИ

- Добавьте новые сферы деятельности компаний.
- Включите дополнительные механизмы взаимодействия компаний, такие как конкуренция и партнерство.
- Реализуйте более сложные правила для определения периода окупаемости и прибыльности компаний.

## ОСОБЕННОСТИ NETLOGO

Модель использует возможности NetLogo для создания и управления агентами, а также для визуализации динамики бюджета компаний и их взаимодействий с государством. Для отсутствующих возможностей были применены workaround'ы, такие как использование глобальных переменных для управления финансированием и кризисами.

## СВЯЗАННЫЕ МОДЕЛИ

- Модели экономической динамики и финансирования в библиотеке моделей NetLogo.
- Модели взаимодействия агентов в условиях ограниченных ресурсов.

## ЗАСЛУГИ И ССЫЛКИ

Ссылка на URL модели в интернете, если она имеется, а также любые другие необходимые заслуги, цитаты и ссылки.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
