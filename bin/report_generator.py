import sys

def run():
    def isTitle(line):
        return line.find('## Running query #') == 0;

    def isStart(line):
        # return line == 'Spark session available as \'spark\'.'
        return line.find('org.apache.spark.sql.AnalysisException') == 0

    def isScore(line):
        return line.find('elapsed: Double = ') == 0

    def isException(line):
        return line.find('Exception') >= 0

    def getScore(line):
        return float(line[len('elapsed: Double = '):])

    def getQueryAndClass(line):
        line = line[len('## Running query #'):]
        sep = line.find(',')
        n = int(line[:sep].strip())
        line = line[sep + 1:].strip()
        return n, line

    def getClassDisplayName(cls, n):
        if cls == 'parquet' or cls == 'Parquet' or cls == 'PARQUET':
            return 'Parquet'
        elif cls.lower().find('parquet') >= 0:
            return 'PQ-%04d' % n
        else:
            return 'CH-%04d' % n

    def getClassTitle(cls, n):
        t = getClassDisplayName(cls, n)
        if t == 'Parquet':
            return t + ": default config"
        return t + ": " + cls

    total = {}
    title = None
    classes = []
    cls = None
    q = -1
    started = False

    while True:
        line = sys.stdin.readline()
        if not line:
            break
        if len(line) == 0:
            continue

        line = line[:-1]
        titleLine = isTitle(line)
        startLine = isStart(line)
        scoreLine = isScore(line)
        exceptionLine = (started and isException(line))

        if not titleLine and not startLine and not scoreLine and not exceptionLine:
            continue

        if titleLine:
            title = line[len('## Running query #'):]
            q, cls = getQueryAndClass(line)
            started = False
            continue

        if startLine:
            started = True
            continue

        if exceptionLine:
            title = None
            continue

        if title == None:
            continue

        score = getScore(line)

        if not total.has_key(cls):
            total[cls] = {}
            classes.append(cls)
        result = total[cls]

        if not result.has_key(q):
            result[q] = (q, cls, score, 1, [score])
        else:
            q, cls, sum, count, array = result[q]
            array.append(score)
            result[q] = (q, cls, sum + score, count + 1, array)

        title = None

    print '## Config and result'
    for i in range(0, len(classes)):
        print '*', getClassTitle(classes[i], i + 1)
    print
    t = '| Query |'
    for i in range(0, len(classes)):
        t += ' %s |' % getClassDisplayName(classes[i], i + 1)
    print t
    t = '| ----- |'
    for _ in classes:
        t += ' ------: |'
    print t
    for i in range(0, 99):
        q = i + 1
        s = '| Q%02d   |' % q
        for cls in classes:
            result = total[cls]
            if not result.has_key(q):
                s += '         |'
            else:
                q, cls, sum, count, array = result[q]
                s += ' %7.1f |' % (sum / count)
        print s

    print

    print '## Raw result data'
    for i in range(0, len(classes)):
        cls = classes[i]
        print '*', getClassTitle(classes[i], i + 1)
        print '```'
        result = total[cls]
        keys = result.keys()
        keys.sort()
        for key in keys:
            q, cls, sum, count, array = result[key]
            print 'Q' + '%02d,' % q, 'avg: %5.1f, detail:' % (sum / count), array
        print '```'

run()
