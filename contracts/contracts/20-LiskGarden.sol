// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LiskGarden {
    // 1. Data Types
    enum GrowthStage { SEED, SPROUT, GROWING, BLOOMING }

    struct Plant {
        uint256 id;
        address owner;
        GrowthStage stage;
        uint256 plantedDate;
        uint256 lastWatered;
        uint8 waterLevel;
        bool exists;
        bool isDead;
    }

    // 2. State
    mapping(uint256 => Plant) public plants;
    mapping(address => uint256[]) public userPlants;
    uint256 public plantCounter;
    address public owner;

    // 3. Constants
    uint256 public constant PLANT_PRICE = 0.001 ether;
    uint256 public constant HARVEST_REWARD = 0.003 ether;
    uint256 public constant STAGE_DURATION = 1 minutes;
    uint256 public constant WATER_DEPLETION_TIME = 30 seconds;
    uint8 public constant WATER_DEPLETION_RATE = 2;

    // 4. Events
    event PlantSeeded(address indexed owner, uint256 indexed plantId);
    event PlantWatered(uint256 indexed plantId, uint8 newWaterLevel);
    event PlantHarvested(uint256 indexed plantId, address indexed owner, uint256 reward);
    event StageAdvanced(uint256 indexed plantId, GrowthStage newStage);
    event PlantDied(uint256 indexed plantId);

    // 5. Constructor
    constructor() { owner = msg.sender; }

    // 6. Main Functions
    function plantSeed() external payable returns (uint256) {
        require(msg.value >= PLANT_PRICE, "ETH tidak cukup");
        plantCounter += 1;
        uint256 plantId = plantCounter;

        plants[plantId] = Plant({
            id: plantId,
            owner: msg.sender,
            stage: GrowthStage.SEED,
            plantedDate: block.timestamp,
            lastWatered: block.timestamp,
            waterLevel: 100,
            exists: true,
            isDead: false
        });

        userPlants[msg.sender].push(plantId);

        emit PlantSeeded(msg.sender, plantId);
        return plantId;
    }

    function calculateWaterLevel(uint256 plantId) public view returns (uint8) {
        Plant memory plant = plants[plantId];
        if (!plant.exists || plant.isDead) return 0;

        uint256 timePassed = block.timestamp - plant.lastWatered;
        uint256 intervals = timePassed / WATER_DEPLETION_TIME;
        uint256 waterLost = intervals * WATER_DEPLETION_RATE;

        if (waterLost >= plant.waterLevel) return 0;
        return plant.waterLevel - uint8(waterLost);
    }

    function updateWaterLevel(uint256 plantId) internal {
        Plant storage plant = plants[plantId];
        if (!plant.exists || plant.isDead) return;

        uint8 currentWater = calculateWaterLevel(plantId);
        plant.waterLevel = currentWater;

        if (currentWater == 0 && !plant.isDead) {
            plant.isDead = true;
            emit PlantDied(plantId);
        }
    }

    function waterPlant(uint256 plantId) external {
        Plant storage plant = plants[plantId];
        require(plant.exists, "Plant tidak ada");
        require(plant.owner == msg.sender, "Bukan owner");
        require(!plant.isDead, "Plant sudah mati");

        plant.waterLevel = 100;
        plant.lastWatered = block.timestamp;

        emit PlantWatered(plantId, plant.waterLevel);
        updatePlantStage(plantId);
    }

    function updatePlantStage(uint256 plantId) public {
        Plant storage plant = plants[plantId];
        require(plant.exists, "Plant tidak ada");

        updateWaterLevel(plantId);
        if (plant.isDead) return;

        uint256 elapsed = block.timestamp - plant.plantedDate;
        GrowthStage oldStage = plant.stage;

        if (elapsed >= 3 * STAGE_DURATION) plant.stage = GrowthStage.BLOOMING;
        else if (elapsed >= 2 * STAGE_DURATION) plant.stage = GrowthStage.GROWING;
        else if (elapsed >= 1 * STAGE_DURATION) plant.stage = GrowthStage.SPROUT;

        if (plant.stage != oldStage) {
            emit StageAdvanced(plantId, plant.stage);
        }
    }

    function harvestPlant(uint256 plantId) external {
        Plant storage plant = plants[plantId];
        require(plant.exists, "Plant tidak ada");
        require(plant.owner == msg.sender, "Bukan owner");
        require(!plant.isDead, "Plant sudah mati");

        updatePlantStage(plantId);
        require(plant.stage == GrowthStage.BLOOMING, "Belum BLOOMING");

        plant.exists = false;
        emit PlantHarvested(plantId, msg.sender, HARVEST_REWARD);

        (bool success, ) = msg.sender.call{value: HARVEST_REWARD}("");
        require(success, "Transfer gagal");
    }

    // 7. Helper Functions
    function getPlant(uint256 plantId) external view returns (Plant memory) {
        Plant memory plant = plants[plantId];
        plant.waterLevel = calculateWaterLevel(plantId);
        return plant;
    }

    function getUserPlants(address user) external view returns (uint256[] memory) {
        return userPlants[user];
    }

    function withdraw() external {
        require(msg.sender == owner, "Bukan owner");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer gagal");
    }

    // 8. Receive ETH
    receive() external payable {}
}