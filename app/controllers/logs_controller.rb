class LogsController < ApplicationController
  def index
    @darts_data = Dart.all

    #ダミーデータ
    dummy_points = [
      # ブル付近
      { x: 500, y: 500, value: 1 }, { x: 510, y: 490, value: 1 },
      { x: 480, y: 520, value: 1 }, { x: 505, y: 515, value: 1 },
      { x: 495, y: 495, value: 1 }, { x: 520, y: 500, value: 1 },
      # 20点付近
      { x: 500, y: 150, value: 1 }, { x: 490, y: 160, value: 1 },
      { x: 510, y: 140, value: 1 }, { x: 495, y: 130, value: 1 },
      { x: 505, y: 155, value: 1 }
    ]
    @heatmap_data = dummy_points
  end
end
