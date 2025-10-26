# 🌿 Proyek Smart Contract: LiskGarden

Proyek **LiskGarden** adalah implementasi *game* berkebun sederhana di blockchain, dikembangkan sebagai bagian dari sesi praktik Solidity. Kontrak ini memungkinkan pengguna untuk menanam, menyiram, dan memanen tanaman digital mereka.

## 💻 Teknologi

* **Solidity**: `^0.8.30`
* **Platform**: EVM (Ethereum Virtual Machine) Compatible Chain (seperti Lisk Layer 2)

## 🎮 Fitur Utama (Kontrak: `LiskGarden.sol`)

Kontrak `LiskGarden` mendefinisikan logika permainan dengan elemen waktu dan manajemen sumber daya air.

### 1. Struktur Tanaman (`Plant`)
Setiap tanaman memiliki data sebagai berikut:
* `id`: ID unik tanaman.
* `owner`: Alamat pemilik.
* `stage`: Tahap pertumbuhan (`SEED`, `SPROUT`, `GROWING`, `BLOOMING`).
* `plantedDate`: Waktu penanaman.
* `lastWatered`: Waktu terakhir disiram.
* `waterLevel`: Tingkat air saat ini (0-100).
* `isDead`: Status apakah tanaman sudah mati.

### 2. Konstanta Game
| Konstanta | Nilai | Deskripsi |
| :--- | :--- | :--- |
| `PLANT_PRICE` | `0.001 ether` | Biaya untuk menanam satu benih. |
| `HARVEST_REWARD` | `0.003 ether` | Hadiah yang didapatkan saat berhasil panen. |
| `STAGE_DURATION` | `1 minutes` | Durasi setiap tahap pertumbuhan. |
| `WATER_DEPLETION_TIME` | `30 seconds` | Interval waktu air berkurang. |
| `WATER_DEPLETION_RATE` | `2` | Jumlah tingkat air yang hilang per interval. |

### 3. Fungsionalitas Inti

* **`plantSeed()`**
    * Memungkinkan pengguna menanam benih dengan mengirimkan minimal `PLANT_PRICE`.
    * Tanaman baru dibuat dengan `stage: SEED` dan `waterLevel: 100`.
    * Memancarkan Event `PlantSeeded`.

* **`waterPlant(uint256 plantId)`**
    * Hanya dapat dipanggil oleh pemilik tanaman.
    * Mengatur ulang `waterLevel` menjadi `100` dan memperbarui `lastWatered`.
    * Memperbarui tahap pertumbuhan tanaman setelah penyiraman.

* **Siklus Pertumbuhan** (`updatePlantStage` & `calculateWaterLevel`)
    * Tahap pertumbuhan maju berdasarkan waktu yang berlalu sejak `plantedDate`.
        * `SPROUT` setelah 1 menit (`1 * STAGE_DURATION`).
        * `GROWING` setelah 2 menit (`2 * STAGE_DURATION`).
        * `BLOOMING` setelah 3 menit (`3 * STAGE_DURATION`).
    * Tingkat air tanaman berkurang seiring waktu. Jika `waterLevel` mencapai 0, tanaman ditandai sebagai mati (`isDead = true`) dan Event `PlantDied` dipancarkan.

* **`harvestPlant(uint256 plantId)`**
    * Membutuhkan tanaman berada pada tahap `BLOOMING`.
    * Mengirimkan `HARVEST_REWARD` kepada pemilik (`msg.sender`).
    * Menghapus tanaman dari status aktif (`exists = false`).

* **`withdraw()`**
    * Memungkinkan *owner* kontrak untuk menarik semua saldo ETH yang tersisa dalam kontrak.

## 📖 Konsep Dasar Solidity yang Dipelajari

Proyek ini juga mencakup praktik dengan berbagai konsep dasar Solidity (dapat dilihat pada file-file pendukung di direktori `contracts/`):

| Konsep | File Contoh | Deskripsi |
| :--- | :--- | :--- |
| **Data Types** | `01-LearnString.sol`, `02-LearnNumber.sol`, `03-LearnBoolean.sol`, `04-LearnAddress.sol` | Mempelajari `string`, `uint`, `bool`, dan `address`. |
| **Struct & Enum** | `06-LearnEnum.sol`, `07-LearnStruct.sol` | Mendefinisikan tipe data kustom dan tahap terstruktur. |
| **Mapping & Array** | `08-LearnMapping.sol`, `09-LearnArray.sol` | Menyimpan data terstruktur dan daftar dinamis. |
| **Error Handling** | `11-LearnRequire.sol`, `19-LearnErrorHandling.sol` | Menggunakan `require` dan `revert` untuk validasi kondisi. |
| **Function Modifier** | `12-LearnModifier.sol` | Membatasi akses fungsi (`onlyOwner`, `onlyPlantOwner`). |
| **Events** | `13-LearnEvents.sol` | Menggunakan Event untuk logging dan komunikasi *off-chain*. |
| **Payable & Transfer ETH** | `14-LearnPayable.sol`, `15-LearnSendETH.sol` | Menggunakan `payable` untuk menerima ETH dan melakukan transfer (`call{value: ...}`). |
| **Visibility & Modifiers** | `17-LearnVisibility.sol`, `18-LearnFunctionModifiers.sol` | Mempelajari visibilitas (`public`, `external`, `internal`, `private`) dan *state mutability* (`view`, `pure`). |