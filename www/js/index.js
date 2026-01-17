/*
 * 喝水打卡应用 - 主逻辑
 */

var app = {
    // 存储键名
    STORAGE_KEY: 'drinkRecords',
    // 当前选中的容量
    selectedVolume: 250,

    // 初始化应用
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
        // 为了方便在浏览器中测试，也监听DOMContentLoaded
        document.addEventListener('DOMContentLoaded', this.onDeviceReady.bind(this), false);
    },

    // 设备准备就绪
    onDeviceReady: function() {
        console.log('应用已就绪');
        this.initVoice();
        this.bindEvents();
        this.loadRecords();
    },

    // 初始化语音
    initVoice: function() {
        if ('speechSynthesis' in window) {
            // 预加载语音列表
            window.speechSynthesis.getVoices();

            // 某些浏览器需要监听语音列表加载完成事件
            if (window.speechSynthesis.onvoiceschanged !== undefined) {
                window.speechSynthesis.onvoiceschanged = function() {
                    console.log('语音列表已加载');
                };
            }
        }
    },

    // 绑定事件
    bindEvents: function() {
        var drinkButton = document.getElementById('drinkButton');
        var clearButton = document.getElementById('clearButton');
        var volumeButtons = document.querySelectorAll('.volume-btn');
        var customVolumeInput = document.getElementById('customVolume');

        drinkButton.addEventListener('click', this.onDrinkClick.bind(this));
        clearButton.addEventListener('click', this.onClearClick.bind(this));

        // 绑定容量按钮事件
        volumeButtons.forEach(function(button) {
            button.addEventListener('click', this.onVolumeButtonClick.bind(this));
        }.bind(this));

        // 绑定自定义容量输入事件
        customVolumeInput.addEventListener('input', this.onCustomVolumeInput.bind(this));
        customVolumeInput.addEventListener('focus', this.onCustomVolumeFocus.bind(this));
    },

    // 点击容量按钮
    onVolumeButtonClick: function(event) {
        var button = event.target;
        var volume = parseInt(button.getAttribute('data-volume'));

        // 更新选中状态
        document.querySelectorAll('.volume-btn').forEach(function(btn) {
            btn.classList.remove('active');
        });
        button.classList.add('active');

        // 清空自定义输入
        document.getElementById('customVolume').value = '';

        // 更新选中容量
        this.selectedVolume = volume;
    },

    // 自定义容量获得焦点
    onCustomVolumeFocus: function() {
        // 取消所有容量按钮的选中状态
        document.querySelectorAll('.volume-btn').forEach(function(btn) {
            btn.classList.remove('active');
        });
    },

    // 自定义容量输入
    onCustomVolumeInput: function(event) {
        var value = parseInt(event.target.value);
        if (value > 0) {
            this.selectedVolume = value;
        }
    },

    // 点击喝水按钮
    onDrinkClick: function() {
        var button = document.getElementById('drinkButton');

        // 添加点击动画
        button.classList.add('clicked');
        setTimeout(function() {
            button.classList.remove('clicked');
        }, 300);

        // 触发点赞动画
        this.showLikeAnimation();

        // 添加打卡记录
        this.addDrinkRecord();
    },

    // 显示点赞动画
    showLikeAnimation: function() {
        var container = document.getElementById('likeAnimationContainer');
        var icons = ['👍', '❤️', '💙', '✨', '🎉', '💪', '👏'];

        // 播放语音"真棒！"
        this.speak('真棒！');

        // 显示"真棒！"文字
        var praiseText = document.createElement('div');
        praiseText.className = 'praise-text';
        praiseText.textContent = '真棒！';
        praiseText.style.left = '50%';
        praiseText.style.top = '50%';
        praiseText.style.transform = 'translate(-50%, -50%)';
        container.appendChild(praiseText);

        // 1.2秒后移除
        setTimeout(function() {
            if (container.contains(praiseText)) {
                container.removeChild(praiseText);
            }
        }, 1200);

        // 随机显示3-5个图标
        var count = 3 + Math.floor(Math.random() * 3);

        for (var i = 0; i < count; i++) {
            // 延迟创建每个图标，产生连续效果
            setTimeout(function(index) {
                var icon = document.createElement('div');
                icon.className = 'like-icon';
                icon.textContent = icons[Math.floor(Math.random() * icons.length)];

                // 随机偏移和旋转
                var xOffset = (Math.random() - 0.5) * 80;
                var rotation = (Math.random() - 0.5) * 40;
                icon.style.setProperty('--x-offset', xOffset + 'px');
                icon.style.setProperty('--rotation', rotation + 'deg');

                container.appendChild(icon);

                // 2秒后移除元素
                setTimeout(function() {
                    container.removeChild(icon);
                }, 2000);
            }.bind(this), i * 150);
        }

        // 显示 +1 效果（显示容量）
        setTimeout(function() {
            var plusOne = document.createElement('div');
            plusOne.className = 'plus-one';
            plusOne.textContent = '+' + this.selectedVolume + 'ml';
            plusOne.style.left = '50%';
            plusOne.style.top = '50%';
            plusOne.style.transform = 'translate(-50%, -50%)';

            container.appendChild(plusOne);

            // 1.5秒后移除
            setTimeout(function() {
                if (container.contains(plusOne)) {
                    container.removeChild(plusOne);
                }
            }, 1500);
        }.bind(this), 200);
    },

    // 添加喝水记录
    addDrinkRecord: function() {
        var now = new Date();
        var record = {
            id: now.getTime(),
            timestamp: now.getTime(),
            date: this.formatDate(now),
            time: this.formatTime(now),
            volume: this.selectedVolume
        };

        // 获取现有记录
        var records = this.getRecords();

        // 添加新记录到开头
        records.unshift(record);

        // 保存记录
        this.saveRecords(records);

        // 更新界面
        this.loadRecords();
    },

    // 获取所有记录
    getRecords: function() {
        var recordsJson = localStorage.getItem(this.STORAGE_KEY);
        if (recordsJson) {
            try {
                return JSON.parse(recordsJson);
            } catch (e) {
                console.error('解析记录失败', e);
                return [];
            }
        }
        return [];
    },

    // 保存记录
    saveRecords: function(records) {
        localStorage.setItem(this.STORAGE_KEY, JSON.stringify(records));
    },

    // 加载并显示记录
    loadRecords: function() {
        var records = this.getRecords();
        var recordsList = document.getElementById('recordsList');
        var emptyMessage = document.getElementById('emptyMessage');
        var todayCountElement = document.getElementById('todayCount');
        var todayVolumeElement = document.getElementById('todayVolume');

        // 清空列表
        recordsList.innerHTML = '';

        if (records.length === 0) {
            emptyMessage.style.display = 'block';
            todayCountElement.textContent = '0';
            todayVolumeElement.textContent = '0';
            return;
        }

        emptyMessage.style.display = 'none';

        // 计算今日喝水次数和总容量
        var today = this.formatDate(new Date());
        var todayRecords = records.filter(function(record) {
            return record.date === today;
        });
        var todayCount = todayRecords.length;
        var todayVolume = todayRecords.reduce(function(sum, record) {
            return sum + (record.volume || 0);
        }, 0);

        todayCountElement.textContent = todayCount;
        todayVolumeElement.textContent = todayVolume;

        // 显示记录
        records.forEach(function(record, index) {
            var recordItem = document.createElement('div');
            recordItem.className = 'record-item';

            var isToday = record.date === today;
            var volume = record.volume || 250; // 向后兼容，默认250ml

            // 格式化完整的日期时间显示
            var dateTimeDisplay = this.formatFullDateTime(record.date, record.time, isToday);

            recordItem.innerHTML =
                '<div class="record-info">' +
                    '<div class="record-icon">💧</div>' +
                    '<div class="record-details">' +
                        '<div class="record-datetime">' + dateTimeDisplay + '</div>' +
                    '</div>' +
                    '<div class="record-volume">' + volume + 'ml</div>' +
                '</div>' +
                '<button class="delete-button" data-id="' + record.id + '">删除</button>';

            recordsList.appendChild(recordItem);

            // 添加淡入动画
            setTimeout(function() {
                recordItem.classList.add('show');
            }, index * 50);
        }.bind(this));

        // 绑定删除按钮事件
        var deleteButtons = recordsList.querySelectorAll('.delete-button');
        deleteButtons.forEach(function(button) {
            button.addEventListener('click', this.onDeleteClick.bind(this));
        }.bind(this));
    },

    // 删除单条记录
    onDeleteClick: function(event) {
        var recordId = parseInt(event.target.getAttribute('data-id'));
        var records = this.getRecords();

        // 过滤掉要删除的记录
        records = records.filter(function(record) {
            return record.id !== recordId;
        });

        this.saveRecords(records);
        this.loadRecords();
    },

    // 清空所有记录
    onClearClick: function() {
        if (confirm('确定要清空所有记录吗？')) {
            localStorage.removeItem(this.STORAGE_KEY);
            this.loadRecords();
        }
    },

    // 格式化日期 YYYY-MM-DD
    formatDate: function(date) {
        var year = date.getFullYear();
        var month = String(date.getMonth() + 1).padStart(2, '0');
        var day = String(date.getDate()).padStart(2, '0');
        return year + '-' + month + '-' + day;
    },

    // 格式化时间 HH:MM:SS
    formatTime: function(date) {
        var hours = String(date.getHours()).padStart(2, '0');
        var minutes = String(date.getMinutes()).padStart(2, '0');
        var seconds = String(date.getSeconds()).padStart(2, '0');
        return hours + ':' + minutes + ':' + seconds;
    },

    // 格式化完整日期时间显示
    formatFullDateTime: function(dateStr, timeStr, isToday) {
        // 解析日期字符串 YYYY-MM-DD
        var dateParts = dateStr.split('-');
        var year = dateParts[0];
        var month = dateParts[1];
        var day = dateParts[2];

        // 格式化为 YYYY年MM月DD日 HH:MM:SS
        var formattedDate = year + '年' + month + '月' + day + '日';

        // 如果是今天，可以显示"今天"或完整日期
        if (isToday) {
            return '今天 ' + timeStr;
        } else {
            return formattedDate + ' ' + timeStr;
        }
    },

    // 语音播放 - 甜美女声
    speak: function(text) {
        // 检查浏览器是否支持语音合成
        if ('speechSynthesis' in window) {
            // 取消之前的语音播放
            window.speechSynthesis.cancel();

            var utterance = new SpeechSynthesisUtterance(text);

            // 获取可用的语音列表
            var voices = window.speechSynthesis.getVoices();

            // 选择中文女声（优先顺序）
            var femaleVoice = null;
            var voicePriority = [
                'Microsoft Huihui - Chinese (Simplified, PRC)',
                'Microsoft Yaoyao - Chinese (Simplified, PRC)',
                'Google 普通话（中国大陆）',
                'zh-CN',
                'zh-TW'
            ];

            // 尝试找到最佳女声
            for (var i = 0; i < voicePriority.length; i++) {
                femaleVoice = voices.find(function(voice) {
                    return voice.name.indexOf(voicePriority[i]) !== -1 ||
                           voice.lang.indexOf(voicePriority[i]) !== -1;
                });
                if (femaleVoice) break;
            }

            // 如果没找到，选择任意中文女声
            if (!femaleVoice) {
                femaleVoice = voices.find(function(voice) {
                    return (voice.lang.indexOf('zh') !== -1 || voice.lang.indexOf('CN') !== -1) &&
                           (voice.name.indexOf('female') !== -1 ||
                            voice.name.indexOf('Female') !== -1 ||
                            voice.name.indexOf('女') !== -1);
                });
            }

            // 如果还没找到，选择任意中文语音
            if (!femaleVoice) {
                femaleVoice = voices.find(function(voice) {
                    return voice.lang.indexOf('zh') !== -1 || voice.lang.indexOf('CN') !== -1;
                });
            }

            // 设置选中的语音
            if (femaleVoice) {
                utterance.voice = femaleVoice;
            }

            // 设置语音参数 - 模拟甜美柔和的声音
            utterance.lang = 'zh-CN'; // 中文
            utterance.rate = 0.85; // 语速：稍慢一点，更温柔
            utterance.pitch = 1.6; // 音调：更高更甜美
            utterance.volume = 1.0; // 音量：最大

            // 播放语音
            window.speechSynthesis.speak(utterance);
        } else {
            console.log('浏览器不支持语音合成');
        }
    }
};

// 启动应用
app.initialize();
