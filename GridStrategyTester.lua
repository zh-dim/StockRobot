local RealDataQuick = require("GridStrategyTester_RealDataExtractor_Quick")

-- ============================================================================
-- GridStrategyTester - Функция тестирования Grid Strategy без реальных операций
-- ============================================================================
-- Назначение: 
--   Тестировать гридовую стратегию путем симуляции изменения цен
--   без совершения реальных операций с расчетом финансового результата
--   при разных значениях trends.step
--
-- Автор: StockRobot Grid Strategy Test Suite
-- Дата: 2025-12-21
-- ============================================================================

-- ============================================================================
-- 1. Инициализация структуры данных для тестирования
-- ============================================================================

local GridTesterConfig = {
  -- Конфигурация тестирования
  logResults = true,           -- Логировать результаты
  saveToFile = true,           -- Сохранять результаты в файл
  verbose = true,              -- Подробный вывод
  
  -- Параметры по умолчанию для теста
  defaultSteps = {
    10,      -- Маленький шаг (микро-гридинг)
    25,      -- Средний шаг
    50,      -- Стандартный шаг
    100,     -- Крупный шаг
    200      -- Очень крупный шаг (макро-гридинг)
  },
  
  -- Типы тестов движения цены
  testPatterns = {
    "sideWay",      -- Боковое движение
    "rampUp",       -- Рост цены
    "rampDown",     -- Падение цены
    "volatile",     -- Волатильное движение
    "triangle"      -- Треугольное движение (вверх-вниз-вверх)
  },
  
  -- Метрики результатов
  metrics = {}
}

-- ============================================================================
-- 2. Основная функция тестирования GridStrategy
-- ============================================================================

function GridStrategyTester(toolKey, trendsConfig, priceSequence, stepValues)
  -- Параметры:
  --   toolKey (string) - ключ инструмента (e.g., "IMOEXF-MMH6")
  --   trendsConfig (table) - конфиг тренда из trends.txt
  --   priceSequence (table) - последовательность PRICE_OFFER и PRICE_BID
  --   stepValues (table) - значения шага сетки для тестирования
  
  local testResults = {
    toolKey = toolKey,
    timestamp = os.date("%Y-%m-%d %H:%M:%S"),
    testCases = {},
    summary = {}
  }
  
  if not stepValues then
    stepValues = GridTesterConfig.defaultSteps
  end
  
  -- Для каждого значения step проводим тест
  for _, stepValue in ipairs(stepValues) do
    local testCase = GridStrategyTestCase(
      toolKey, 
      trendsConfig, 
      priceSequence, 
      stepValue
    )
    table.insert(testResults.testCases, testCase)
  end
  
  -- Вычисляем сводку результатов
  testResults.summary = CalculateTestSummary(testResults.testCases)
  
  -- Вывод результатов
  if GridTesterConfig.logResults then
    messageTestResults(testResults)
  end
  
  if GridTesterConfig.saveToFile then
    SaveTestResultsToFile(testResults)
  end
  
  return testResults
end

-- ============================================================================
-- 3. Отдельный тест-кейс для конкретного значения step
-- ============================================================================

function GridStrategyTestCase(toolKey, trendsConfig, priceSequence, stepValue)
  -- Инициализация тест-кейса
  local testCase = {
    toolKey = toolKey,
    step = stepValue,
    initialTrendsConfig = DeepCopy(trendsConfig),
    
    -- Результаты тестирования
    gridLevels = {
      buy = {},
      sell = {}
    },
    
    tradingHistory = {},
    financialResults = {
      totalBuys = 0,
      totalSells = 0,
      completedPairs = 0,
      openPositions = 0,
      totalProfit = 0,
      totalLoss = 0,
      netResult = 0,
      profitFactor = 0,
      maxDrawdown = 0,
      winRate = 0
    },
    
    metrics = {
      levelsTriggered = 0,
      ordersSimulated = 0,
      averageSpread = 0,
      efficiency = 0
    },
    
    priceMovement = {
      min = math.huge,
      max = 0,
      range = 0,
      volatility = 0
    }
  }
  
  -- Копируем конфиг тренда для изменения step
  local simulatedTrends = DeepCopy(trendsConfig)
  simulatedTrends.step = stepValue
  
  -- Инициализируем гридовые уровни
  local initialBuyPrice = priceSequence[1].offer - (stepValue * 2)
  local initialSellPrice = priceSequence[1].bid + (stepValue * 2)
  
  testCase.gridLevels.buy = InitializeGridLevels(
    "buy", 
    initialBuyPrice, 
    stepValue, 
    5  -- количество уровней
  )
  
  testCase.gridLevels.sell = InitializeGridLevels(
    "sell", 
    initialSellPrice, 
    stepValue, 
    5
  )
  
  -- Симуляция движения цены через все последовательности
  SimulatePriceMovement(testCase, priceSequence, stepValue)
  
  -- Расчет финансовых результатов
  CalculateFinancialResults(testCase, stepValue)
  
  -- Расчет метрик эффективности
  CalculatePerformanceMetrics(testCase)
  
  return testCase
end

-- ============================================================================
-- 4. Инициализация уровней сетки
-- ============================================================================

function InitializeGridLevels(direction, basePrice, step, levelCount)
  local levels = {}
  
  for i = 1, levelCount do
    local price
    local level = {
      index = i,
      ordersID = 0,           -- Не создаем реальные ордера
      tradeprice = 0,         -- Цена выполнения
      stopprice = 0,          -- Цена стопа
      multiplier = 1,         -- Множитель (1 по умолчанию)
      status = "PENDING",     -- PENDING, TRIGGERED, EXECUTED
      triggerTime = 0,
      spreadOnTrigger = 0
    }
    
    if direction == "buy" then
      price = basePrice - (i - 1) * step
    else  -- sell
      price = basePrice + (i - 1) * step
    end
    
    level.price1 = price
    table.insert(levels, level)
  end
  
  return levels
end

-- ============================================================================
-- 5. Симуляция движения цены
-- ============================================================================

function SimulatePriceMovement(testCase, priceSequence, stepValue)
  local buyLevels = testCase.gridLevels.buy
  local sellLevels = testCase.gridLevels.sell
  local tradingHistory = testCase.tradingHistory
  
  local priceMin = math.huge
  local priceMax = 0
  local levelsTriggered = 0
  
  -- Проходим через каждую цену в последовательности
  for idx, priceData in ipairs(priceSequence) do
    local currentBid = priceData.bid
    local currentOffer = priceData.offer
    local timestamp = priceData.timestamp or idx
    
    -- Отслеживание диапазона цен
    if currentBid < priceMin then priceMin = currentBid end
    if currentOffer > priceMax then priceMax = currentOffer end
    
    -- Проверка уровней BUY (цена падает)
    for _, level in ipairs(buyLevels) do
      if level.status == "PENDING" and currentBid <= level.price1 then
        level.status = "TRIGGERED"
        level.tradeprice = currentBid
        level.triggerTime = timestamp
        level.spreadOnTrigger = currentOffer - currentBid
        levelsTriggered = levelsTriggered + 1
        
        local trade = {
          type = "buy",
          level = level.index,
          triggerPrice = currentBid,
          spreadAtTrigger = level.spreadOnTrigger,
          timestamp = timestamp,
          status = "PARTIAL"  -- Ищем противоположный уровень
        }
        table.insert(tradingHistory, trade)
      end
    end
    
    -- Проверка уровней SELL (цена растет)
    for _, level in ipairs(sellLevels) do
      if level.status == "PENDING" and currentOffer >= level.price1 then
        level.status = "TRIGGERED"
        level.tradeprice = currentOffer
        level.triggerTime = timestamp
        level.spreadOnTrigger = currentOffer - currentBid
        levelsTriggered = levelsTriggered + 1
        
        local trade = {
          type = "sell",
          level = level.index,
          triggerPrice = currentOffer,
          spreadAtTrigger = level.spreadOnTrigger,
          timestamp = timestamp,
          status = "PARTIAL"
        }
        table.insert(tradingHistory, trade)
      end
    end
  end
  
  -- Сохраняем метрики движения цены
  testCase.priceMovement.min = priceMin
  testCase.priceMovement.max = priceMax
  testCase.priceMovement.range = priceMax - priceMin
  testCase.priceMovement.volatility = CalculateVolatility(priceSequence)
  testCase.metrics.levelsTriggered = levelsTriggered
end

-- ============================================================================
-- 6. Расчет финансовых результатов
-- ============================================================================

function CalculateFinancialResults(testCase, stepValue)
  local history = testCase.tradingHistory
  local financials = testCase.financialResults
  
  local buys = {}
  local sells = {}
  local completedTrades = {}
  
  -- Разделяем покупки и продажи
  for _, trade in ipairs(history) do
    if trade.type == "buy" then
      table.insert(buys, trade)
    else
      table.insert(sells, trade)
    end
  end
  
  financials.totalBuys = #buys
  financials.totalSells = #sells
  
  -- Сопоставляем покупки и продажи для замкнутых пар
  local pairedTrades = MatchBuysAndSells(buys, sells, stepValue)
  
  for _, pair in ipairs(pairedTrades) do
    local buyPrice = pair.buy.triggerPrice
    local sellPrice = pair.sell.triggerPrice
    local spread = sellPrice - buyPrice
    
    local profitPerUnit = spread - pair.buy.spreadAtTrigger - pair.sell.spreadAtTrigger
    
    if spread > 0 then
      financials.totalProfit = financials.totalProfit + profitPerUnit
      financials.completedPairs = financials.completedPairs + 1
    else
      financials.totalLoss = financials.totalLoss + profitPerUnit
    end
    
    table.insert(completedTrades, {
      buyPrice = buyPrice,
      sellPrice = sellPrice,
      spread = spread,
      profit = profitPerUnit,
      netRatio = profitPerUnit / stepValue
    })
  end
  
  -- Открытые позиции (не спаренные)
  financials.openPositions = math.abs(financials.totalBuys - financials.totalSells)
  
  -- Чистый результат
  financials.netResult = financials.totalProfit + financials.totalLoss
  
  -- Коэффициент прибыльности (Profit Factor)
  if financials.totalLoss ~= 0 then
    financials.profitFactor = math.abs(financials.totalProfit / financials.totalLoss)
  else
    financials.profitFactor = (financials.totalProfit > 0) and math.huge or 0
  end
  
  -- Процент выигрышных сделок
  if financials.completedPairs > 0 then
    local winningPairs = 0
    for _, trade in ipairs(completedTrades) do
      if trade.profit > 0 then
        winningPairs = winningPairs + 1
      end
    end
    financials.winRate = (winningPairs / financials.completedPairs) * 100
  end
  
  -- Хранить завершенные сделки для анализа
  financials.completedTrades = completedTrades
end

-- ============================================================================
-- 7. Сопоставление покупок и продаж
-- ============================================================================

function MatchBuysAndSells(buys, sells, stepValue)
  local paired = {}
  local usedBuys = {}
  local usedSells = {}
  
  -- Для каждой покупки ищем ближайшую продажу
  for _, buy in ipairs(buys) do
    local bestSell = nil
    local bestSpread = math.huge
    local bestSellIdx = nil
    
    for sellIdx, sell in ipairs(sells) do
      -- Ищем первую продажу ВЫШЕ цены покупки
      if sell.triggerPrice > buy.triggerPrice and not usedSells[sellIdx] then
        local spread = sell.triggerPrice - buy.triggerPrice
        if spread < bestSpread then
          bestSpread = spread
          bestSell = sell
          bestSellIdx = sellIdx
        end
      end
    end
    
    if bestSell and bestSpread < stepValue * 5 then  -- Спред не больше 5 шагов
      usedSells[bestSellIdx] = true
      table.insert(paired, {
        buy = buy,
        sell = bestSell
      })
    end
  end
  
  return paired
end

-- ============================================================================
-- 8. Расчет метрик эффективности
-- ============================================================================

function CalculatePerformanceMetrics(testCase)
  local metrics = testCase.metrics
  local financials = testCase.financialResults
  
  -- Средний спред при срабатывании уровней
  local totalSpread = 0
  local spreadCount = 0
  
  for _, trade in ipairs(testCase.tradingHistory) do
    totalSpread = totalSpread + trade.spreadAtTrigger
    spreadCount = spreadCount + 1
  end
  
  if spreadCount > 0 then
    metrics.averageSpread = totalSpread / spreadCount
  end
  
  -- Эффективность стратегии
  -- (Завершенные пары / Всего уровней срабатывания) * Коэффициент прибыльности
  if metrics.levelsTriggered > 0 then
    metrics.efficiency = (financials.completedPairs / metrics.levelsTriggered) * 
                        (1 + math.min(financials.profitFactor, 1))
  end
  
  -- Максимальное просадание
  local maxProfit = 0
  local currentProfit = 0
  
  for _, trade in ipairs(testCase.financialResults.completedTrades or {}) do
    currentProfit = currentProfit + trade.profit
    if currentProfit > maxProfit then
      maxProfit = currentProfit
    end
  end
  
  for _, trade in ipairs(testCase.financialResults.completedTrades or {}) do
    currentProfit = currentProfit + trade.profit
    local drawdown = maxProfit - currentProfit
    if drawdown > testCase.financialResults.maxDrawdown then
      testCase.financialResults.maxDrawdown = drawdown
    end
  end
end

-- ============================================================================
-- 9. Расчет волатильности
-- ============================================================================

function CalculateVolatility(priceSequence)
  if #priceSequence < 2 then return 0 end
  
  local returns = {}
  local avgPrice = 0
  
  -- Вычисляем средние цены (mid price)
  for _, priceData in ipairs(priceSequence) do
    local midPrice = (priceData.bid + priceData.offer) / 2
    table.insert(returns, midPrice)
    avgPrice = avgPrice + midPrice
  end
  
  avgPrice = avgPrice / #returns
  
  -- Стандартное отклонение (волатильность)
  local variance = 0
  for _, midPrice in ipairs(returns) do
    variance = variance + (midPrice - avgPrice) ^ 2
  end
  
  variance = variance / #returns
  return math.sqrt(variance)
end

-- ============================================================================
-- 10. Расчет сводки результатов тестирования
-- ============================================================================

function CalculateTestSummary(testCases)
  local summary = {
    totalTestCases = #testCases,
    bestStep = nil,
    bestProfit = -math.huge,
    worstProfit = math.huge,
    averageProfit = 0,
    bestProfitFactor = 0,
    averageEfficiency = 0,
    stepComparison = {}
  }
  
  for _, testCase in ipairs(testCases) do
    local profit = testCase.financialResults.netResult
    local profitFactor = testCase.financialResults.profitFactor
    local efficiency = testCase.metrics.efficiency
    
    summary.averageProfit = summary.averageProfit + profit
    summary.averageEfficiency = summary.averageEfficiency + efficiency
    
    if profit > summary.bestProfit then
      summary.bestProfit = profit
      summary.bestStep = testCase.step
    end
    
    if profit < summary.worstProfit then
      summary.worstProfit = profit
    end
    
    if profitFactor > summary.bestProfitFactor then
      summary.bestProfitFactor = profitFactor
    end
    
    table.insert(summary.stepComparison, {
      step = testCase.step,
      profit = profit,
      completedPairs = testCase.financialResults.completedPairs,
      profitFactor = profitFactor,
      winRate = testCase.financialResults.winRate,
      efficiency = efficiency
    })
  end
  
  if #testCases > 0 then
    summary.averageProfit = summary.averageProfit / #testCases
    summary.averageEfficiency = summary.averageEfficiency / #testCases
  end
  
  return summary
end

-- ============================================================================
-- 11. Вывод результатов на экран
-- ============================================================================

function messageTestResults(results)
  message("\n" .. string.rep("=", 80))
  message("GRID STRATEGY TESTER - РЕЗУЛЬТАТЫ")
  message(string.rep("=", 80))
  message("Инструмент: " .. results.toolKey)
  message("Время теста: " .. results.timestamp)
  message(string.rep("-", 80))
  
  -- Для каждого тест-кейса
  for _, testCase in ipairs(results.testCases) do
    message("\n[STEP = " .. testCase.step .. "]")
    message("-" .. string.rep("-", 78))
    
    local fin = testCase.financialResults
    local met = testCase.metrics
    local pm = testCase.priceMovement
    
    message(string.format("Движение цены:     Min=%.2f  Max=%.2f  Range=%.2f  Volatility=%.4f", 
                        pm.min, pm.max, pm.range, pm.volatility))
    
    message(string.format("Финансовые результаты:"))
    message(string.format("  Покупок: %d | Продаж: %d | Замкнутых пар: %d | Открытых позиций: %d",
                        fin.totalBuys, fin.totalSells, fin.completedPairs, fin.openPositions))
    
    message(string.format("  Прибыль: %.2f | Убыток: %.2f | Нетто: %.2f",
                        fin.totalProfit, fin.totalLoss, fin.netResult))
    
    message(string.format("  Profit Factor: %.4f | Win Rate: %.2f%%",
                        fin.profitFactor, fin.winRate))
    
    message(string.format("Метрики стратегии:"))
    message(string.format("  Срабатываний уровней: %d | Средний спред: %.4f",
                        met.levelsTriggered, met.averageSpread))
    message(string.format("  Эффективность: %.4f | Макс. просадание: %.2f",
                        met.efficiency, fin.maxDrawdown))
  end
  
  -- Сводка
  message("\n" .. string.rep("=", 80))
  message("СВОДКА РЕЗУЛЬТАТОВ ТЕСТИРОВАНИЯ")
  message(string.rep("=", 80))
  
  local summary = results.summary
  message(string.format("Всего тест-кейсов: %d", summary.totalTestCases))
  message(string.format("Лучший шаг (step): %s | Макс прибыль: %.2f",
                      tostring(summary.bestStep), summary.bestProfit))
  message(string.format("Минимальная прибыль: %.2f | Средняя прибыль: %.2f",
                      summary.worstProfit, summary.averageProfit))
  message(string.format("Лучший Profit Factor: %.4f", summary.bestProfitFactor))
  message(string.format("Средняя эффективность: %.4f", summary.averageEfficiency))
  
  message("\nСРАВНЕНИЕ ШАГОВ СЕТКИ:")
  message(string.rep("-", 80))
  message(string.format("%-10s %-12s %-10s %-12s %-10s %-12s",
                      "Step", "Profit", "Pairs", "ProfitFact", "WinRate%", "Efficiency"))
  message(string.rep("-", 80))
  
  for _, comp in ipairs(summary.stepComparison) do
    message(string.format("%-10d %-12.2f %-10d %-12.4f %-10.2f %-12.4f",
                        comp.step, comp.profit, comp.completedPairs, 
                        comp.profitFactor, comp.winRate, comp.efficiency))
  end
  
  message(string.rep("=", 80) .. "\n")
end

-- ============================================================================
-- 12. Сохранение результатов в файл
-- ============================================================================

function SaveTestResultsToFile(results)
  local filePath = getScriptPath() .. "//GridStrategy_TestResults_" .. 
                   os.date("%Y%m%d_%H%M%S") .. ".txt"
  
  local file = io.open(filePath, "w")
  if not file then return false end
  
  file:write("=" .. string.rep("=", 79) .. "\n")
  file:write("GRID STRATEGY TESTER - ПОЛНЫЕ РЕЗУЛЬТАТЫ\n")
  file:write("=" .. string.rep("=", 79) .. "\n\n")
  
  file:write("Инструмент: " .. results.toolKey .. "\n")
  file:write("Время теста: " .. results.timestamp .. "\n\n")
  
  -- Детальные результаты каждого теста
  for _, testCase in ipairs(results.testCases) do
    file:write("\n" .. string.rep("-", 80) .. "\n")
    file:write("ТЕСТ: Step = " .. testCase.step .. "\n")
    file:write(string.rep("-", 80) .. "\n\n")
    
    local fin = testCase.financialResults
    local met = testCase.metrics
    local pm = testCase.priceMovement
    
    file:write("ДВИЖЕНИЕ ЦЕНЫ:\n")
    file:write(string.format("  Минимальная цена: %.4f\n", pm.min))
    file:write(string.format("  Максимальная цена: %.4f\n", pm.max))
    file:write(string.format("  Диапазон: %.4f\n", pm.range))
    file:write(string.format("  Волатильность: %.6f\n\n", pm.volatility))
    
    file:write("ФИНАНСОВЫЕ РЕЗУЛЬТАТЫ:\n")
    file:write(string.format("  Всего покупок: %d\n", fin.totalBuys))
    file:write(string.format("  Всего продаж: %d\n", fin.totalSells))
    file:write(string.format("  Замкнутых пар: %d\n", fin.completedPairs))
    file:write(string.format("  Открытых позиций: %d\n", fin.openPositions))
    file:write(string.format("  Общая прибыль: %.2f\n", fin.totalProfit))
    file:write(string.format("  Общий убыток: %.2f\n", fin.totalLoss))
    file:write(string.format("  Нетто результат: %.2f\n", fin.netResult))
    file:write(string.format("  Profit Factor: %.4f\n", fin.profitFactor))
    file:write(string.format("  Win Rate: %.2f%%\n", fin.winRate))
    file:write(string.format("  Max Drawdown: %.2f\n\n", fin.maxDrawdown))
    
    file:write("МЕТРИКИ СТРАТЕГИИ:\n")
    file:write(string.format("  Срабатываний уровней: %d\n", met.levelsTriggered))
    file:write(string.format("  Средний спред: %.6f\n", met.averageSpread))
    file:write(string.format("  Эффективность: %.6f\n", met.efficiency))
    
    -- Завершенные сделки
    if fin.completedTrades and #fin.completedTrades > 0 then
      file:write("\nДЕТАЛИ ЗАВЕРШЕННЫХ СДЕЛОК:\n")
      file:write(string.format("%-10s %-10s %-10s %-10s %-10s\n",
                               "Buy Price", "Sell Price", "Spread", "Profit", "Ratio"))
      file:write(string.rep("-", 50) .. "\n")
      
      for _, trade in ipairs(fin.completedTrades) do
        file:write(string.format("%-10.4f %-10.4f %-10.4f %-10.4f %-10.4f\n",
                                 trade.buyPrice, trade.sellPrice, trade.spread,
                                 trade.profit, trade.netRatio))
      end
    end
  end
  
  -- Сводка
  file:write("\n" .. string.rep("=", 80) .. "\n")
  file:write("СВОДКА\n")
  file:write(string.rep("=", 80) .. "\n\n")
  
  local summary = results.summary
  file:write(string.format("Всего тест-кейсов: %d\n", summary.totalTestCases))
  file:write(string.format("Лучший шаг (step): %s\n", tostring(summary.bestStep)))
  file:write(string.format("Максимальная прибыль: %.2f\n", summary.bestProfit))
  file:write(string.format("Минимальная прибыль: %.2f\n", summary.worstProfit))
  file:write(string.format("Средняя прибыль: %.2f\n", summary.averageProfit))
  file:write(string.format("Лучший Profit Factor: %.4f\n", summary.bestProfitFactor))
  file:write(string.format("Средняя эффективность: %.4f\n\n", summary.averageEfficiency))
  
  file:write("ТАБЛИЦА СРАВНЕНИЯ ШАГОВ:\n")
  file:write(string.rep("-", 80) .. "\n")
  file:write(string.format("%-10s %-15s %-12s %-15s %-12s %-15s\n",
                           "Step", "Profit", "Pairs", "ProfitFactor", "WinRate%", "Efficiency"))
  file:write(string.rep("-", 80) .. "\n")
  
  for _, comp in ipairs(summary.stepComparison) do
    file:write(string.format("%-10d %-15.2f %-12d %-15.4f %-12.2f %-15.4f\n",
                             comp.step, comp.profit, comp.completedPairs,
                             comp.profitFactor, comp.winRate, comp.efficiency))
  end
  
  file:write("\n" .. string.rep("=", 80) .. "\n")
  file:close()
  
  message("Результаты сохранены в: " .. filePath)
  return true
end

-- ============================================================================
-- 13. Вспомогательные функции
-- ============================================================================

-- Глубокое копирование таблицы
function DeepCopy(original)
  local copy = {}
  for k, v in pairs(original) do
    if type(v) == "table" then
      copy[k] = DeepCopy(v)
    else
      copy[k] = v
    end
  end
  return copy
end

-- ============================================================================
-- 14. ПРИМЕР ИСПОЛЬЗОВАНИЯ
-- ============================================================================

function main()
-- Подготовка тестовых данных
local toolKey = "IMOEXF-MMH6"

-- Конфиг тренда (из trends.txt)
local trendsConfig = {
  key = toolKey,
  enable = true,
  mode = "grid",
  op1 = "B",
  op2 = "S",
  seccode1 = "IMOEXF",
  seccode2 = "MMH6",
  step = 50,
  stepvol = 5,
  MaxProfit = 5000,
  MinStop = 100000000,
  MaxStop = 0,
  buy = {},
  sell = {}
}

-- Последовательность цен (в формате: {bid, offer, timestamp})
-- Пример: боковое движение в диапазоне 3200-3220
local priceSequence = {
  { bid = 3210, offer = 3211, timestamp = 1 },
  { bid = 3205, offer = 3206, timestamp = 2 },
  { bid = 3200, offer = 3201, timestamp = 3 },  -- Срабатывает BUY уровень
  { bid = 3202, offer = 3203, timestamp = 4 },
  { bid = 3208, offer = 3209, timestamp = 5 },
  { bid = 3215, offer = 3216, timestamp = 6 },  -- Срабатывает SELL уровень
  { bid = 3210, offer = 3211, timestamp = 7 },
  { bid = 3205, offer = 3206, timestamp = 8 },
  { bid = 3200, offer = 3201, timestamp = 9 },  -- Срабатывает второй BUY
  { bid = 3212, offer = 3213, timestamp = 10 }, -- Срабатывает второй SELL
}



-- Загружаем реальные данные с графика QUIK
local backtest = RealDataQuick.LoadDataForBacktestQuick("price")
local priceSequence = backtest.priceSequence


-- Значения шагов для тестирования
local stepValues = {10, 25, 50, 100, 200}

-- ЗАПУСК ТЕСТА
local results = GridStrategyTester(toolKey, trendsConfig, priceSequence, stepValues)

-- Результаты доступны в таблице results с полной статистикой


-- ============================================================================
-- ЭКСПОРТ ФУНКЦИЙ
-- ============================================================================

return {
  GridStrategyTester = GridStrategyTester,
  GridStrategyTestCase = GridStrategyTestCase,
  CalculateTestSummary = CalculateTestSummary,
  messageTestResults = messageTestResults,
  SaveTestResultsToFile = SaveTestResultsToFile,
  GridTesterConfig = GridTesterConfig
}
end