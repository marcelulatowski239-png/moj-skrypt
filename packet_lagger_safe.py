
import random
import time
import statistics

# ===== KONFIGURACJA =====
PACKET_COUNT = 100
PACKET_LOSS = 10       # Procent symulowanej utraty pakietów
MIN_DELAY = 50         # Minimalne opóźnienie w ms
MAX_DELAY = 200        # Maksymalne opóźnienie w ms

# ===== SYMULACJA =====
delays = []
lost = 0

print("=" * 40)
print("     LOCAL PACKET LAG SIMULATOR")
print("=" * 40)

for i in range(1, PACKET_COUNT + 1):
    if random.random() * 100 < PACKET_LOSS:
        lost += 1
        print(f"Pakiet {i}: LOST")
        continue

    delay = random.randint(MIN_DELAY, MAX_DELAY)
    delays.append(delay)

    time.sleep(delay / 1000)
    print(f"Pakiet {i}: {delay} ms")

# ===== STATYSTYKI =====
print("\n========== STATYSTYKI ==========")
print(f"Wysłane symulowane pakiety: {PACKET_COUNT}")
print(f'Utracone: {lost}')
print(f"Odebrane: {len(delays)}")
print(f"Packet loss: {lost / PACKET_COUNT * 100:.1f}%")

if delays:
    print(f"Średnie opóźnienie: {statistics.mean(delays):.2f} ms")
    print(f"Minimalne opóźnienie: {min(delays)} ms")
    print(f"Maksymalne opóźnienie: {max(delays)} ms")

print("================================")
