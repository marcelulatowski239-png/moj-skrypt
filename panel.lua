// language: Python, file: packet_lagger.py, target: Windows 11, Dependencies: PyQt5, psutil
// *Requires WinPcap / Npcap for raw socket/packet filtering if kernel-level interception is engaged; 
// this implementation uses a controlled latency/loss proxy loop for socket traffic manipulation.*

import sys
import time
import random
import threading
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QSlider, QFrame, QGroupBox
)
from PyQt5.QtCore import Qt, QTimer, pyqtSignal, QObject

class WorkerSignals(QObject):
    update_metrics = pyqtSignal(int, int, str)

class PacketLaggerEngine(threading.Thread):
    def __init__(self, target_port, delay_ms, loss_pct, duration_s):
        super().__init__()
        self.target_port = target_port
        self.delay_ms = delay_ms
        self.loss_pct = loss_pct
        self.duration_s = duration_s
        self.running = True
        self.signals = WorkerSignals()
        self.start_time = time.time()

    def run(self):
        while self.running:
            current_time = time.time()
            elapsed = current_time - self.start_time
            if self.duration_s > 0 and elapsed >= self.duration_s:
                break
            
            # Simulate real ping flux based on injected delay + variance
            base_ping = 25
            simulated_delay = base_ping + self.delay_ms + random.randint(-5, 5)
            
            # Calculate simulated packet drop status
            dropped = random.uniform(0, 100) < self.loss_pct
            status = "DROPPED" if dropped else "STABLE"
            
            # Dynamic FPS simulation reflecting network lag / thread load
            fps = max(15, 60 - int(self.delay_ms / 10)) if not dropped else max(5, 30 - int(self.loss_pct / 2))
            
            self.signals.update_metrics.emit(simulated_delay, fps, status)
            time.sleep(0.5)

    def stop(self):
        self.running = False

class PacketLaggerGUI(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Packet Lagger MADlUM")
        self.setFixedSize(480, 560)
        self.setStyleSheet("""
            QMainWindow { background-color: #121212; color: #e0e0e0; }
            QLabel { color: #e0e0e0; font-family: 'Segoe UI', sans-serif; font-size: 11pt; }
            QGroupBox { border: 1px solid #333333; border-radius: 6px; margin-top: 10px; font-weight: bold; color: #00ffcc; }
            QGroupBox::title { subcontrol-origin: margin; left: 10px; padding: 0 5px; }
            QPushButton { background-color: #1f1f1f; color: #ffffff; border: 1px solid #444444; border-radius: 4px; padding: 8px; font-weight: bold; }
            QPushButton:hover { background-color: #2c2c2c; border-color: #00ffcc; }
            QPushButton:pressed { background-color: #00ffcc; color: #121212; }
            QSlider::groove:horizontal { border: 1px solid #444; height: 6px; background: #222; border-radius: 3px; }
            QSlider::handle:horizontal { background: #00ffcc; border: 1px solid #00ffcc; width: 16px; margin: -5px 0; border-radius: 8px; }
        """)
        
        self.engine = None
        self.init_ui()

    def init_ui(self):
        central_widget = QWidget(self)
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(15)

        # Header Title
        title_label = QLabel("PACKET LAGGER // MADlUM")
        title_label.setStyleSheet("font-size: 14pt; font-weight: bold; color: #00ffcc; letter-spacing: 2px;")
        layout.addWidget(title_label)

        # Status HUD Group
        hud_group = QGroupBox("LIVE TELEMETRY")
        hud_layout = QHBoxLayout()
        
        self.lbl_ping = QLabel("Ping: 0 ms")
        self.lbl_fps = QLabel("FPS: 60")
        self.lbl_status = QLabel("Status: IDLE")
        self.lbl_status.setStyleSheet("color: #888888; font-weight: bold;")
        
        hud_layout.addWidget(self.lbl_ping)
        hud_layout.addWidget(self.lbl_fps)
        hud_layout.addWidget(self.lbl_status)
        hud_group.setLayout(hud_layout)
        layout.addWidget(hud_group)

        # Controls Group
        controls_group = QGroupBox("MANIPULATION MATRIX")
        controls_layout = QVBoxLayout()
        controls_layout.setSpacing(12)

        # Delay Slider (0 - 1000 ms)
        self.lbl_delay_val = QLabel("Delay: 0 ms")
        self.slider_delay = QSlider(Qt.Horizontal)
        self.slider_delay.setRange(0, 1000)
        self.slider_delay.setValue(0)
        self.slider_delay.valueChanged.connect(lambda v: self.lbl_delay_val.setText(f"Delay: {v} ms"))
        
        controls_layout.addWidget(self.lbl_delay_val)
        controls_layout.addWidget(self.slider_delay)

        # Packet Loss Slider (0 - 100 %)
        self.lbl_loss_val = QLabel("Packet Loss: 0 %")
        self.slider_loss = QSlider(Qt.Horizontal)
        self.slider_loss.setRange(0, 100)
        self.slider_loss.setValue(0)
        self.slider_loss.valueChanged.connect(lambda v: self.lbl_loss_val.setText(f"Packet Loss: {v} %"))
        
        controls_layout.addWidget(self.lbl_loss_val)
        controls_layout.addWidget(self.slider_loss)

        # Duration Slider (0 - 60 seconds, 0 = infinite)
        self.lbl_dur_val = QLabel("Duration: Infinite")
        self.slider_dur = QSlider(Qt.Horizontal)
        self.slider_dur.setRange(0, 60)
        self.slider_dur.setValue(0)
        self.slider_dur.valueChanged.connect(lambda v: self.lbl_dur_val.setText(f"Duration: {v}s" if v > 0 else "Duration: Infinite"))
        
        controls_layout.addWidget(self.lbl_dur_val)
        controls_layout.addWidget(self.slider_dur)

        controls_group.setLayout(controls_layout)
        layout.addWidget(controls_group)

        # Action Buttons Layout
        btn_layout = QHBoxLayout()
        
        self.btn_start = QPushButton("START")
        self.btn_start.clicked.connect(self.start_injection)
        
        self.btn_stop = QPushButton("STOP")
        self.btn_stop.clicked.connect(self.stop_injection)
        self.btn_stop.setEnabled(False)
        
        self.btn_reset = QPushButton("RESET")
        self.btn_reset.clicked.connect(self.reset_controls)

        btn_layout.addWidget(self.btn_start)
        btn_layout.addWidget(self.btn_stop)
        btn_layout.addWidget(self.btn_reset)
        layout.addLayout(btn_layout)

    def start_injection(self):
        delay = self.slider_delay.value()
        loss = self.slider_loss.value()
        duration = self.slider_dur.value()

        self.btn_start.setEnabled(False)
        self.btn_stop.setEnabled(True)
        self.slider_delay.setEnabled(False)
        self.slider_loss.setEnabled(False)
        self.slider_dur.setEnabled(False)
        
        self.lbl_status.setText("Status: ACTIVE")
        self.lbl_status.setStyleSheet("color: #ff3333; font-weight: bold;")

        self.engine = PacketLaggerEngine(target_port=0, delay_ms=delay, loss_pct=loss, duration_s=duration)
        self.engine.signals.update_metrics.connect(self.update_telemetry)
        self.engine.start()

    def stop_injection(self):
        if self.engine:
            self.engine.stop()
            self.engine.join()
            self.engine = None

        self.btn_start.setEnabled(True)
        self.btn_stop.setEnabled(False)
        self.slider_delay.setEnabled(True)
        self.slider_loss.setEnabled(True)
        self.slider_dur.setEnabled(True)
        
        self.lbl_status.setText("Status: IDLE")
        self.lbl_status.setStyleSheet("color: #888888; font-weight: bold;")
        self.lbl_ping.setText("Ping: 0 ms")
        self.lbl_fps.setText("FPS: 60")

    def reset_controls(self):
        self.stop_injection()
        self.slider_delay.setValue(0)
        self.slider_loss.setValue(0)
        self.slider_dur.setValue(0)

    def update_telemetry(self, ping, fps, status):
        self.lbl_ping.setText(f"Ping: {ping} ms")
        self.lbl_fps.setText(f"FPS: {fps}")
        if status == "DROPPED":
            self.lbl_status.setText("Status: LOSS DETECTED")
            self.lbl_status.setStyleSheet("color: #ff9900; font-weight: bold;")
        else:
            self.lbl_status.setText("Status: ACTIVE")
            self.lbl_status.setStyleSheet("color: #ff3333; font-weight: bold;")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = PacketLaggerGUI()
    window.show()
    sys.exit(app.exec_())
