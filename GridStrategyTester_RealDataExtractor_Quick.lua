-- ============================================================================
-- GridStrategyTester_RealDataExtractor - ДОПОЛНЕНИЕ
-- Быстрые функции для получения свечей через готовый код QUIK
-- ============================================================================

local RealDataExtractorQuick = {}

-- ============================================================================
-- БЫСТРАЯ ФУНКЦИЯ #1 - Получение свечей через getNumCandles
-- ============================================================================

function RealDataExtractorQuick.GetCandlesQuick(priceSource)
  --[[
  БЫСТРЫЙ способ получения свечей используя готовый код QUIK:
  
  local barnum = getNumCandles("price")
  local price, BarNprice, toolprice = getCandlesByIndex("price", 0, 0, barnum)
  
  Параметры:
    priceSource - источник цены (обычно "price", может быть другое имя таблицы)
  
  Возвращает:
    Массив свечей или nil если ошибка
    
    {
      {index=1, open=3210, close=3215, high=3220, low=3200, volume=1000, bid=3210, offer=3211},
      {index=2, open=3215, close=3220, high=3225, low=3210, volume=1200, bid=3220, offer=3221},
      ...
    }
  
  Использование:
    local candles = RealDataExtractorQuick.GetCandlesQuick("price")
    if candles then
      message("? Получено " .. #candles .. " свечей")
    end
  
  Это САМЫЙ БЫСТРЫЙ способ, так как использует готовый код QUIK
  ]]
  
  priceSource = priceSource or "price"
  
  -- Проверяем что QUIK API доступен
  if not getNumCandles then
    error("GetCandlesQuick: getNumCandles not available in QUIK API")
    return nil
  end
  
  if not getCandlesByIndex then
    error("GetCandlesQuick: getCandlesByIndex not available in QUIK API")
    return nil
  end
  
  -- Получаем количество свечей доступных
  local barnum = getNumCandles(priceSource)
  
  if not barnum or barnum <= 0 then
    error("GetCandlesQuick: No candles available for source: " .. priceSource)
    return nil
  end
  
  -- Получаем все свечи сразу (ГОТОВЫЙ КОД QUIK)
  local price, BarNprice, toolprice = getCandlesByIndex(priceSource, 0, 0, barnum)
  
  if not price or #price == 0 then
    error("GetCandlesQuick: Failed to get candles from: " .. priceSource)
    return nil
  end
  
  -- Преобразуем в стандартный формат
  local candles = {}
  for i, candle in ipairs(price) do
    -- Берем данные из полученной свечи, если их нет - используем close как базу
    local closePrice = candle.close or 0
    
    table.insert(candles, {
      index = i,
      open = candle.open or closePrice,
      close = closePrice,
      high = candle.high or closePrice,
      low = candle.low or closePrice,
      volume = candle.volume or 0,
      -- bid/offer рассчитываем на основе close
      bid = closePrice - 0.5,
      offer = closePrice + 0.5,
      timestamp = i
    })
  end
  
  return candles
end

-- ============================================================================
-- БЫСТРАЯ ФУНКЦИЯ #2 - Полная загрузка для бэктеста через готовый код
-- ============================================================================

function RealDataExtractorQuick.LoadDataForBacktestQuick(priceSource)
  --[[
  ПОЛНАЯ загрузка данных для тестирования используя готовый QUIK код
  
  Параметры:
    priceSource - источник цены (обычно "price")
  
  Возвращает:
    {
      priceSource = "price",
      candles = {...},
      priceSequence = {...},
      stats = {...},
      barCount = количество свечей,
      timestamp = os.date()
    }
  
  Использование:
    local backtest = RealDataExtractorQuick.LoadDataForBacktestQuick("price")
    if backtest then
      message("? Загружено " .. backtest.barCount .. " свечей")
      local GridTester = require("GridStrategyTester")
      local results = GridTester.GridStrategyTester(
        "IMOEXF-MMH6", Trends["IMOEXF-MMH6"],
        backtest.priceSequence, {25, 50, 100, 200}
      )
    end
  ]]
  
  priceSource = priceSource or "price"
  
  message(string.format("\n? Загрузка данных из '%s'...", priceSource))
  
  -- Получаем свечи через QUIK API
  local candles = RealDataExtractorQuick.GetCandlesQuick(priceSource)
  
  if not candles then
    message(string.format("? Ошибка: Не удалось получить свечи из '%s'", priceSource))
    return nil
  end
  
  message(string.format("? Получено %d свечей", #candles))
  
  -- Преобразуем в формат для GridStrategyTester
  local priceSequence = RealDataExtractorQuick.ConvertCandlesToPriceSequence(candles)
  
  if not priceSequence or #priceSequence == 0 then
    message("? Ошибка: Не удалось преобразовать данные")
    return nil
  end
  
  message(string.format("? Преобразовано в %d ценовых точек", #priceSequence))
  
  -- Анализируем данные
  local stats = RealDataExtractorQuick.AnalyzeCandleStats(candles)
  
  if stats then
    message(string.format("\n?? Статистика:")
      .. "\n  Диапазон: %.2f - %.2f (%.2f пипсов)", 
      stats.minPrice, stats.maxPrice, stats.priceRange)
    message(string.format("  Волатильность: %.4f", stats.volatility))
    message(string.format("  Средний объем: %.0f\n", stats.avgVolume))
  end
  
  return {
    priceSource = priceSource,
    candles = candles,
    priceSequence = priceSequence,
    stats = stats,
    barCount = #candles,
    timestamp = os.date("%Y-%m-%d %H:%M:%S")
  }
end

-- ============================================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================================

function RealDataExtractorQuick.ConvertCandlesToPriceSequence(candles)
  --[[
  Преобразует свечи из QUIK в формат для GridStrategyTester
  
  Входной формат (от QUIK):
    {index=1, open=3210, close=3215, high=3220, low=3200, volume=1000}
  
  Выходной формат (для GridStrategyTester):
    {bid=3210, offer=3211, timestamp=1}
  ]]
  
  if not candles or #candles == 0 then
    return {}
  end
  
  local priceSequence = {}
  
  for i, candle in ipairs(candles) do
    local closePrice = candle.close or (candle.high + candle.low) / 2
    
    table.insert(priceSequence, {
      bid = closePrice - 1,
      offer = closePrice + 1,
      open = candle.open,
      close = candle.close,
      high = candle.high,
      low = candle.low,
      volume = candle.volume,
      timestamp = candle.index or i
    })
  end
  
  return priceSequence
end

function RealDataExtractorQuick.AnalyzeCandleStats(candles)
  --[[
  Анализирует статистику полученных свечей
  ]]
  
  if not candles or #candles == 0 then
    return nil
  end
  
  local stats = {
    count = #candles,
    minPrice = math.huge,
    maxPrice = 0,
    sumPrice = 0,
    totalVolume = 0,
    priceList = {}
  }
  
  -- Собираем статистику
  for _, candle in ipairs(candles) do
    local price = candle.close or (candle.high + candle.low) / 2
    
    if price < stats.minPrice then stats.minPrice = price end
    if price > stats.maxPrice then stats.maxPrice = price end
    
    stats.sumPrice = stats.sumPrice + price
    stats.totalVolume = stats.totalVolume + (candle.volume or 0)
    
    table.insert(stats.priceList, price)
  end
  
  stats.avgPrice = stats.sumPrice / #candles
  stats.avgVolume = stats.totalVolume / #candles
  stats.priceRange = stats.maxPrice - stats.minPrice
  
  -- Волатильность (стандартное отклонение)
  local variance = 0
  for _, price in ipairs(stats.priceList) do
    variance = variance + (price - stats.avgPrice) ^ 2
  end
  stats.volatility = math.sqrt(variance / #candles)
  
  return stats
end

-- ============================================================================
-- ПРАКТИЧЕСКИЕ ПРИМЕРЫ
-- ============================================================================

function RealDataExtractorQuick.Example_QuickTest()
  --[[
  Пример 1: Быстрый тест с загруженными свечами
  
  Использование:
    RealDataExtractorQuick.Example_QuickTest()
  ]]
  
  message("\n=== ПРИМЕР 1: БЫСТРЫЙ ТЕСТ ===\n")
  
  -- Загружаем данные
  local backtest = RealDataExtractorQuick.LoadDataForBacktestQuick("price")
  
  if not backtest then
    message("? Не удалось загрузить данные")
    return
  end
  
  -- Подключаем GridStrategyTester
  local GridTester = require("GridStrategyTester")
  
  -- Тестируем с разными step
  local results = GridTester.GridStrategyTester(
    "IMOEXF-MMH6",
    Trends["IMOEXF-MMH6"],
    backtest.priceSequence,
    {25, 50, 100, 200}
  )
  
  if results then
    message("\n? Тестирование завершено!")
    message("Лучший step: " .. results.summary.bestStep)
    message("Макс прибыль: " .. results.summary.bestProfit)
  end
end

function RealDataExtractorQuick.Example_AnalyzeVolatility()
  --[[
  Пример 2: Анализ волатильности текущего графика
  
  Использование:
    RealDataExtractorQuick.Example_AnalyzeVolatility()
  ]]
  
  message("\n=== ПРИМЕР 2: АНАЛИЗ ВОЛАТИЛЬНОСТИ ===\n")
  
  -- Загружаем данные
  local backtest = RealDataExtractorQuick.LoadDataForBacktestQuick("price")
  
  if not backtest then
    return
  end
  
  -- Выводим анализ
  local stats = backtest.stats
  message("?? Анализ графика:")
  message(string.format("  Свечей: %d", stats.count))
  message(string.format("  Диапазон: %.2f - %.2f", stats.minPrice, stats.maxPrice))
  message(string.format("  Средняя цена: %.2f", stats.avgPrice))
  message(string.format("  Волатильность: %.4f", stats.volatility))
  message(string.format("  Средний объем: %.0f", stats.avgVolume))
  
  -- Рекомендация по step
  local recommendedStep
  if stats.volatility < 1.0 then
    recommendedStep = 25
    message("\n?? Рекомендуемый step: " .. recommendedStep .. " (низкая волатильность, боковой рынок)")
  elseif stats.volatility < 2.0 then
    recommendedStep = 50
    message("\n?? Рекомендуемый step: " .. recommendedStep .. " (нормальная волатильность)")
  elseif stats.volatility < 3.0 then
    recommendedStep = 100
    message("\n?? Рекомендуемый step: " .. recommendedStep .. " (повышенная волатильность)")
  else
    recommendedStep = 150
    message("\n?? Рекомендуемый step: " .. recommendedStep .. " (высокая волатильность)")
  end
end

function RealDataExtractorQuick.Example_IntegrateWithStockRobot()
  --[[
  Пример 3: Интеграция с StockRobot для ежедневной оптимизации
  
  Добавить в main() функции StockRobot.lua
  ]]
  
  local code = [[
-- Добавить в main() функции StockRobot.lua:

local RealDataQuick = require("GridStrategyTester_RealDataExtractor_Quick")
local GridTester = require("GridStrategyTester")

-- В основной цикл (один раз в день, например в 9:00):
function OptimizeGridParametersQuick()
  if os.date("%H") == "09" and os.date("%M") < "30" then
    message("\n? Оптимизация Grid параметров...\n")
    
    -- Загружаем текущие данные графика
    local backtest = RealDataQuick.LoadDataForBacktestQuick("price")
    
    if backtest then
      -- Тестируем текущий инструмент
      local toolKey = "IMOEXF-MMH6"  -- Или динамически из переменной
      
      if tool[toolKey] and Trends[toolKey] then
        local results = GridTester.GridStrategyTester(
          toolKey,
          Trends[toolKey],
          backtest.priceSequence,
          {Trends[toolKey].step - 25, Trends[toolKey].step, Trends[toolKey].step + 25}
        )
        
        if results.summary.bestProfit > 0 then
          local oldStep = Trends[toolKey].step
          Trends[toolKey].step = results.summary.bestStep
          SaveTrends = true
          
          message(string.format("? Step обновлен: %d > %d (прибыль: %.2f)\n",
            oldStep, Trends[toolKey].step, results.summary.bestProfit))
        end
      end
    end
  end
end

-- Вызывать в основном цикле:
OptimizeGridParametersQuick()
  ]]
  
  message(code)
end

-- ============================================================================
-- ЭКСПОРТ МОДУЛЯ
-- ============================================================================

return RealDataExtractorQuick

-- ============================================================================
-- БЫСТРЫЕ ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ
-- ============================================================================

--[[

-- ПРИМЕР 1: Загрузить и протестировать
local RealDataQuick = require("GridStrategyTester_RealDataExtractor_Quick")
local GridTester = require("GridStrategyTester")

local backtest = RealDataQuick.LoadDataForBacktestQuick("price")
if backtest then
  local results = GridTester.GridStrategyTester(
    "IMOEXF-MMH6", Trends["IMOEXF-MMH6"],
    backtest.priceSequence, {25, 50, 100, 200}
  )
  message("Лучший step: " .. results.summary.bestStep)
end

-- ПРИМЕР 2: Быстро получить свечи
local candles = RealDataQuick.GetCandlesQuick("price")
if candles then
  message("Получено " .. #candles .. " свечей")
  message("Min: " .. candles[1].low .. ", Max: " .. candles[1].high)
end

-- ПРИМЕР 3: Анализ волатильности
RealDataQuick.Example_AnalyzeVolatility()

-- ПРИМЕР 4: Быстрый тест
RealDataQuick.Example_QuickTest()

]]