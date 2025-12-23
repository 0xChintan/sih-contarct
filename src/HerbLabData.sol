// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title HerbLabData
 * @notice Stores lab analysis data for herb batches
 */
contract HerbLabData {
    struct LabRecord {
        // Basic metadata
        uint256 batchId;
        string sampleCondition;    // e.g., Intact / Damaged / Moist
        string packagingIntegrity; // e.g., Sealed / Compromised
        string samplingDate;       // dd-mm-yyyy
        string technicianName;
        string remarks;

        // Organoleptic/physical
        string moistureContent; // % (string to allow ranges/notes)
        string pHLevel;         // pH (string to allow decimals)
        string colorCheck;      // observed color
        string odorCheck;       // odor description
        string foreignMatter;   // % (string to allow decimals)

        // Chemical
        string leadPpm;
        string arsenicPpm;
        string cadmiumPpm;
        string mercuryPpm;
        string pesticideResidues; // notes/result
        string aflatoxinsPpb;

        // Microbial
        string totalBacterialCount; // CFU/g
        string yeastMold;           // CFU/g
        string salmonella;          // Present/Absent
        string eColi;               // Present/Absent

        uint256 recordedAt;
        address recordedBy;
        bool exists;
    }

    struct LabInput {
        // Basic metadata
        string sampleCondition;
        string packagingIntegrity;
        string samplingDate;
        string technicianName;
        string remarks;

        // Organoleptic/physical
        string moistureContent;
        string pHLevel;
        string colorCheck;
        string odorCheck;
        string foreignMatter;

        // Chemical
        string leadPpm;
        string arsenicPpm;
        string cadmiumPpm;
        string mercuryPpm;
        string pesticideResidues;
        string aflatoxinsPpb;

        // Microbial
        string totalBacterialCount;
        string yeastMold;
        string salmonella;
        string eColi;
    }

    mapping(uint256 => LabRecord) private labData;

    event LabDataRecorded(uint256 indexed batchId, address indexed recordedBy);

    /**
     * @notice Record or update lab data for a batch
     * @dev Overwrite is allowed; uncomment guard to block if needed
     */
    function recordLabData(uint256 batchId, LabInput calldata input) external {
        require(batchId > 0, "batchId required");
        // require(!labData[batchId].exists, "already recorded");

        LabRecord memory newRec = LabRecord({
            batchId: batchId,
            sampleCondition: input.sampleCondition,
            packagingIntegrity: input.packagingIntegrity,
            samplingDate: input.samplingDate,
            technicianName: input.technicianName,
            remarks: input.remarks,
            moistureContent: input.moistureContent,
            pHLevel: input.pHLevel,
            colorCheck: input.colorCheck,
            odorCheck: input.odorCheck,
            foreignMatter: input.foreignMatter,
            leadPpm: input.leadPpm,
            arsenicPpm: input.arsenicPpm,
            cadmiumPpm: input.cadmiumPpm,
            mercuryPpm: input.mercuryPpm,
            pesticideResidues: input.pesticideResidues,
            aflatoxinsPpb: input.aflatoxinsPpb,
            totalBacterialCount: input.totalBacterialCount,
            yeastMold: input.yeastMold,
            salmonella: input.salmonella,
            eColi: input.eColi,
            recordedAt: block.timestamp,
            recordedBy: msg.sender,
            exists: true
        });

        labData[batchId] = newRec;

        emit LabDataRecorded(batchId, msg.sender);
    }

    function getLabData(uint256 batchId) external view returns (LabRecord memory) {
        require(labData[batchId].exists, "not found");
        return labData[batchId];
    }
}
