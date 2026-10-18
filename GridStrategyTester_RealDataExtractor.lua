-- ============================================================================
-- GridStrategyTester_RealDataExtractor - Получение реальных данных с графика
-- Функции для загрузки свечей из QUIK терминала через getCandlesByIndex
-- ============================================================================

local RealDataExtractor = {}

-- ============================================================================
-- ГЛАВНАЯ ФУНКЦИЯ - Получение свечей с графика
-- ============================================================================

function RealDataExtractor.GetCandlesFromChart(classCode, secCode, timeframe, barCount)
  --[[
  Получает свечи с графика QUIK через QUIK.api
  
  Параметры:
    classCode   - Класс инструмента (например, "SPBFUT")
    secCode     - Код бумаги (например, "IMOEXF")
    timeframe   - Временной фрейм в минутах (1, 5, 10, 15, 30, 60, etc.)
    barCount    - Количество свечей для получения (рекомендуемо 100-500)
  
  Возвращает:
    {
      {bid = 3210, offer = 3211, close = 3211, open = 3205, high = 3215, low = 3200, vol = 1000, timestamp = 1234567890},
      {bid = 3215, offer = 3216, close = 3216, open = 3211, high = 3220, low = 3210, vol = 1500, timestamp = 1234568890},
      ...
    }
    
    ИЛИ nil если ошибка
  
  Использование:
    local candles = RealDataExtractor.GetCandlesFromChart("SPBFUT", "IMOEXF", 30, 100)
    if candles then
      print("Получено " .. #candles .. " свечей")
    end
  ]]
  
  if not classCode or not secCode then
    error("GetCandlesFromChart: Missing classCode or secCode")
    return nil
  end
  
  timeframe = timeframe or 30  -- По умолчанию 30 минут
  barCount = barCount or 100   -- По умолчанию 100 свечей
  
  -- Проверка что QUIK API доступен
  if not getQuoteLevel2 then
    error("GetCandlesFromChart: QUIK API not available")
    return nil
  end
  
  local candles = {}
  
  -- Получаем текущий номер последней свечи
  local lastCandle = getCandlesByIndex(classCode, secCode, timeframe, 0, 1)
  if not lastCandle or #lastCandle == 0 then
    error("GetCandlesFromChart: Failed to get chart data")
    return nil
  end
  
  local lastCandleIndex = lastCandle[1].index
  local startIndex = math.max(0, lastCandleIndex - barCount)
  
  -- Получаем свечи блоками по 500 (ограничение QUIK)
  local blockSize = 500
  local currentIndex = startIndex
  
  while currentIndex <= lastCandleIndex do
    local remaining = lastCandleIndex - currentIndex + 1
    local toFetch = math.min(blockSize, remaining)
    
    -- Получаем блок свечей
    local candleBlock = getCandlesByIndex(
      classCode,
      secCode,
      timeframe,
      currentIndex,
      toFetch
    )
    
    if not candleBlock or #candleBlock == 0 then
      break
    end
    
    -- Преобразуем в стандартный формат
    for _, candle in ipairs(candleBlock) do
      table.insert(candles, {
        index = candle.index,
        open = candle.open,
        close = candle.close,
        high = candle.high,
        low = candle.low,
        volume = candle.volume or 0,
        bid = candle.close - 0.5,  -- Приблизительно (реальные bid/ask могут отличаться)
        offer = candle.close + 0.5,
        timestamp = candle.datetime or 0
      })
    end
    
    currentIndex = currentIndex + toFetch
  end
  
  if #candles == 0 then
    error("GetCandlesFromChart: No candles retrieved")
    return nil
  end
  
  return candles
end

-- ============================================================================
-- ФУНКЦИЯ - Получение свечей для конкретного инструмента
-- ============================================================================

function RealDataExtractor.GetCandlesForTool(toolKey, timeframe, barCount)
  --[[
  Получает свечи для инструмента, используя конфиг из tool.txt
  
  Параметры:
    toolKey   - Ключ инструмента (например, "IMOEXF-MMH6")
    timeframe - Временной фрейм в минутах (30 для 30мин)
    barCount  - Количество свечей (100-500 рекомендуется)
  
  Требует глобальной переменной tool (загруженной из tool.txt)
  
  Возвращает:
    Массив свечей или nil
  
  Использование:
    local candles = RealDataExtractor.GetCandlesForTool("IMOEXF-MMH6", 30, 100)
  ]]
  
  if not toolKey then
    error("GetCandlesForTool: Missing toolKey")
    return nil
  end
  
  -- Проверяем что инструмент существует (требует глобальную переменную tool)
  if not tool or not tool[toolKey] then
    error("GetCandlesForTool: Tool not found: " .. toolKey)
    return nil
  end
  
  local toolData = tool[toolKey]
  
  -- Получаем seccode первого инструмента
  if not toolData.seccode1 or not toolData.seccode1.seccode then
    error("GetCandlesForTool: Invalid tool configuration")
    return nil
  end
  
  local secCode = toolData.seccode1.seccode
  local classCode = toolData.seccode1.class_code or "SPBFUT"
  
  timeframe = timeframe or 30
  barCount = barCount or 100
  
  return RealDataExtractor.GetCandlesFromChart(classCode, secCode, timeframe, barCount)
end

-- ============================================================================
-- ФУНКЦИЯ - Получение свечей для обоих инструментов в паре
-- ============================================================================

function RealDataExtractor.GetCandlesForToolPair(toolKey, timeframe, barCount)
  --[[
  Получает свечи для ОБОИХ инструментов в паре (seccode1 и seccode2)
  
  Возвращает:
    {
      seccode1 = { название = "IMOEXF", candles = {...} },
      seccode2 = { название = "MMH6", candles = {...} }
    }
    
  Использование:
    local pair = RealDataExtractor.GetCandlesForToolPair("IMOEXF-MMH6", 30, 100)
    if pair then
      print("IMOEXF свечей: " .. #pair.seccode1.candles)
      print("MMH6 свечей: " .. #pair.seccode2.candles)
    end
  ]]
  
  if not toolKey or not tool or not tool[toolKey] then
    error("GetCandlesForToolPair: Invalid tool")
    return nil
  end
  
  local toolData = tool[toolKey]
  timeframe = timeframe or 30
  barCount = barCount or 100
  
  local result = {}
  
  -- Получаем свечи для первого инструмента
  if toolData.seccode1 and toolData.seccode1.seccode then
    local sec1Code = toolData.seccode1.seccode
    local class1Code = toolData.seccode1.class_code or "SPBFUT"
    
    result.seccode1 = {
      name = sec1Code,
      classCode = class1Code,
      candles = RealDataExtractor.GetCandlesFromChart(class1Code, sec1Code, timeframe, barCount)
    }
  end
  
  -- Получаем свечи для второго инструмента
  if toolData.seccode2 and toolData.seccode2.seccode then
    local sec2Code = toolData.seccode2.seccode
    local class2Code = toolData.seccode2.class_code or "SPBFUT"
    
    result.seccode2 = {
      name = sec2Code,
      classCode = class2Code,
      candles = RealDataExtractor.GetCandlesFromChart(class2Code, sec2Code, timeframe, barCount)
    }
  end
  
  return result
end

-- ============================================================================
-- ФУНКЦИЯ - Получение последней свечи
-- ============================================================================

function RealDataExtractor.GetLastCandle(classCode, secCode, timeframe)
  --[[
  Получает только ПОСЛЕДНЮЮ свечу (текущую или последнюю завершенную)
  
  Параметры:
    classCode - Класс инструмента
    secCode   - Код бумаги
    timeframe - Временной фрейм в минутах
  
  Возвращает:
    {index = 12345, open = 3210, close = 3215, high = 3220, low = 3200, volume = 1000}
    
  Использование:
    local lastCandle = RealDataExtractor.GetLastCandle("SPBFUT", "IMOEXF", 30)
  ]]
  
  if not classCode or not secCode then
    return nil
  end
  
  timeframe = timeframe or 30
  
  local candles = getCandlesByIndex(classCode, secCode, timeframe, 0, 1)
  if candles and #candles > 0 then
    return candles[1]
  end
  
  return nil
end

-- ============================================================================
-- ФУНКЦИЯ - Преобразование свечей в формат для GridStrategyTester
-- ============================================================================

function RealDataExtractor.ConvertCandlesToPriceSequence(candles)
  --[[
  Преобразует свечи из QUIK в формат для GridStrategyTester
  
  Входной формат (от QUIK):
    {index = 12345, open = 3210, close = 3215, high = 3220, low = 3200, volume = 1000}
  
  Выходной формат (для GridStrategyTester):
    {bid = 3210, offer = 3211, timestamp = 1}
  
  Использование:
    local quikCandles = RealDataExtractor.GetCandlesFromChart("SPBFUT", "IMOEXF", 30, 100)
    local priceSequence = RealDataExtractor.ConvertCandlesToPriceSequence(quikCandles)
  ]]
  
  if not candles or #candles == 0 then
    return {}
  end
  
  local priceSequence = {}
  
  for i, candle in ipairs(candles) do
    -- Используем close как основу, bid/offer рассчитываем
    local closePrice = candle.close or (candle.high + candle.low) / 2
    
    table.insert(priceSequence, {
      bid = closePrice - 1,  -- Приблизительно (размер спреда может варьироваться)
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

-- ============================================================================
-- ФУНКЦИЯ - Загрузка данных для тестирования стратегии
-- ============================================================================

function RealDataExtractor.LoadDataForBacktest(toolKey, timeframe, barCount)
  --[[
  Полная функция загрузки данных для бэктеста
  
  Возвращает готовый набор данных для GridStrategyTester
  
  Использование:
    local backtest = RealDataExtractor.LoadDataForBacktest("IMOEXF-MMH6", 30, 100)
    if backtest then
      local GridTester = require("GridStrategyTester")
      local results = GridTester.GridStrategyTester(
        "IMOEXF-MMH6",
        Trends["IMOEXF-MMH6"],
        backtest.priceSequence,
        {25, 50, 100, 200}
      )
    end
  ]]
  
  if not toolKey then
    print("LoadDataForBacktest: Missing toolKey")
    return nil
  end
  
  timeframe = timeframe or 30
  barCount = barCount or 100
  
  print(string.format("\nЗагрузка данных для %s (%d мин, %d свечей)...",
    toolKey, timeframe, barCount))
  
  -- Получаем свечи для инструмента
  local candles = RealDataExtractor.GetCandlesForTool(toolKey, timeframe, barCount)
  
  if not candles then
    print("Ошибка: Не удалось получить свечи")
    return nil
  end
  
  print(string.format("✅ Получено %d свечей", #candles))
  
  -- Преобразуем в формат для GridStrategyTester
  local priceSequence = RealDataExtractor.ConvertCandlesToPriceSequence(candles)
  
  if not priceSequence or #priceSequence == 0 then
    print("Ошибка: Не удалось преобразовать данные")
    return nil
  end
  
  print(string.format("✅ Преобразовано в %d ценовых точек", #priceSequence))
  
  -- Анализируем данные
  local stats = RealDataExtractor.AnalyzeCandleStats(candles)
  
  return {
    toolKey = toolKey,
    timeframe = timeframe,
    barCount = barCount,
    candles = candles,
    priceSequence = priceSequence,
    stats = stats,
    timestamp = os.date("%Y-%m-%d %H:%M:%S")
  }
end

-- ============================================================================
-- ФУНКЦИЯ - Анализ статистики свечей
-- ============================================================================

function RealDataExtractor.AnalyzeCandleStats(candles)
  --[[
  Анализирует статистику полученных свечей
  
  Возвращает:
    {
      count = 100,
      minPrice = 3200,
      maxPrice = 3220,
      avgPrice = 3210,
      volatility = 2.5,
      totalVolume = 50000,
      avgVolume = 500,
      priceRange = 20
    }
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
    sumVolume = 0,
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
-- ФУНКЦИЯ - Получение исторических данных за день
-- ============================================================================

function RealDataExtractor.GetHistoricalDataForDay(classCode, secCode, dayOffset)
  --[[
  Получает данные за конкретный день (может быть в прошлом)
  
  Параметры:
    classCode - Класс инструмента
    secCode   - Код бумаги
    dayOffset - Смещение в днях (0 = сегодня, -1 = вчера, -2 = позавчера)
  
  Рекомендация: Использовать timeframe=1 (1 минута) для максимальной точности
  
  Использование:
    local yesterday = RealDataExtractor.GetHistoricalDataForDay("SPBFUT", "IMOEXF", -1)
  ]]
  
  dayOffset = dayOffset or 0
  
  -- Получаем свечи за день с временным фреймом 1 минута
  local candles = RealDataExtractor.GetCandlesFromChart(
    classCode,
    secCode,
    1,        -- 1 минута для максимальной детальности
    1440      -- 1440 минут = 24 часа
  )
  
  if not candles then
    return nil
  end
  
  return candles
end

-- ============================================================================
-- ФУНКЦИЯ - Экспорт данных в файл
-- ============================================================================

function RealDataExtractor.ExportCandlesToFile(candles, filename)
  --[[
  Экспортирует свечи в текстовый файл для анализа
  
  Использование:
    local candles = RealDataExtractor.GetCandlesFromChart("SPBFUT", "IMOEXF", 30, 100)
    RealDataExtractor.ExportCandlesToFile(candles, "candles_imoex.txt")
  ]]
  
  if not candles or #candles == 0 then
    print("ExportCandlesToFile: No candles to export")
    return false
  end
  
  filename = filename or "candles_export.txt"
  local filepath = (getScriptPath or ".") .. "/" .. filename
  
  local file = io.open(filepath, "w")
  if not file then
    print("ExportCandlesToFile: Cannot open file: " .. filepath)
    return false
  end
  
  -- Заголовок
  file:write("Index\tOpen\tClose\tHigh\tLow\tVolume\n")
  file:write(string.rep("-", 80) .. "\n")
  
  -- Данные
  for _, candle in ipairs(candles) do
    file:write(string.format("%d\t%.2f\t%.2f\t%.2f\t%.2f\t%d\n",
      candle.index or 0,
      candle.open or 0,
      candle.close or 0,
      candle.high or 0,
      candle.low or 0,
      candle.volume or 0
    ))
  end
  
  file:close()
  
  print(string.format("✅ Экспортировано %d свечей в: %s", #candles, filepath))
  return true
end

-- ============================================================================
-- ФУНКЦИЯ - Получение данных для всех инструментов в tool.txt
-- ============================================================================

function RealDataExtractor.GetDataForAllTools(timeframe, barCount)
  --[[
  Загружает данные для ВСЕХ инструментов из tool.txt
  
  Требует глобальную переменную tool
  
  Возвращает:
    {
      ["IMOEXF-MMH6"] = { candles = {...}, stats = {...} },
      ["USDRUBF-SiH6"] = { candles = {...}, stats = {...} },
      ...
    }
  
  Использование:
    local allData = RealDataExtractor.GetDataForAllTools(30, 100)
    for toolKey, data in pairs(allData) do
      print(toolKey .. ": " .. #data.candles .. " свечей")
    end
  ]]
  
  if not tool then
    print("GetDataForAllTools: Global tool variable not found")
    return nil
  end
  
  timeframe = timeframe or 30
  barCount = barCount or 100
  
  local allData = {}
  
  for toolKey, _ in pairs(tool) do
    print(string.format("\nЗагрузка %s...", toolKey))
    
    local candles = RealDataExtractor.GetCandlesForTool(toolKey, timeframe, barCount)
    
    if candles then
      allData[toolKey] = {
        candles = candles,
        stats = RealDataExtractor.AnalyzeCandleStats(candles),
        priceSequence = RealDataExtractor.ConvertCandlesToPriceSequence(candles)
      }
      print(string.format("✅ %s: %d свечей", toolKey, #candles))
    else
      print(string.format("❌ %s: Ошибка загрузки", toolKey))
    end
  end
  
  return allData
end

-- ============================================================================
-- ЭКСПОРТ МОДУЛЯ
-- ============================================================================

return RealDataExtractor

-- ============================================================================
-- ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ
-- ============================================================================

--[[

-- Пример 1: Получить свечи для одного инструмента
local RealData = require("GridStrategyTester_RealDataExtractor")
local candles = RealData.GetCandlesFromChart("SPBFUT", "IMOEXF", 30, 100)

-- Пример 2: Получить данные для тестирования
local backtest = RealData.LoadDataForBacktest("IMOEXF-MMH6", 30, 100)
if backtest then
  local GridTester = require("GridStrategyTester")
  local results = GridTester.GridStrategyTester(
    "IMOEXF-MMH6",
    Trends["IMOEXF-MMH6"],
    backtest.priceSequence,
    {25, 50, 100, 200}
  )
end

-- Пример 3: Анализ данных
local stats = RealData.AnalyzeCandleStats(candles)
print("Min: " .. stats.minPrice)
print("Max: " .. stats.maxPrice)
print("Volatility: " .. stats.volatility)

-- Пример 4: Экспорт в файл
RealData.ExportCandlesToFile(candles, "imoex_history.txt")

-- Пример 5: Получить данные для всех инструментов
local allData = RealData.GetDataForAllTools(30, 100)
for toolKey, data in pairs(allData) do
  print(toolKey .. ": " .. #data.candles .. " свечей, volatility=" .. data.stats.volatility)
end

]]