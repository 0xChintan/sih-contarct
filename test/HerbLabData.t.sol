// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {HerbLabData} from "../src/HerbLabData.sol";

contract HerbLabDataTest is Test {
    HerbLabData private lab;

    function setUp() public {
        lab = new HerbLabData();
    }

    function testRecordAndFetch() public {
        uint256 batchId = 1;
        HerbLabData.LabInput memory input = HerbLabData.LabInput({
            sampleCondition: "Intact",
            packagingIntegrity: "Sealed",
            samplingDate: "01-01-2025",
            technicianName: "Tech A",
            remarks: "All good",
            moistureContent: "10%",
            pHLevel: "6.5",
            colorCheck: "Green",
            odorCheck: "Herbal",
            foreignMatter: "0.1%",
            leadPpm: "0.01",
            arsenicPpm: "0.02",
            cadmiumPpm: "0.03",
            mercuryPpm: "0.04",
            pesticideResidues: "None detected",
            aflatoxinsPpb: "5 ppb",
            totalBacterialCount: "1e3",
            yeastMold: "5e2",
            salmonella: "Absent",
            eColi: "Absent"
        });

        lab.recordLabData(batchId, input);

        HerbLabData.LabRecord memory rec = lab.getLabData(batchId);
        assertEq(rec.batchId, batchId);
        assertEq(rec.moistureContent, "10%");
        assertEq(rec.pHLevel, "6.5");
        assertEq(rec.sampleCondition, "Intact");
        assertEq(rec.packagingIntegrity, "Sealed");
        assertEq(rec.technicianName, "Tech A");
        assertEq(rec.exists, true);
        assertEq(rec.recordedBy, address(this));
        assertGt(rec.recordedAt, 0);
    }

    function testRevertWhenNotFound() public {
        vm.expectRevert("not found");
        lab.getLabData(999);
    }
}





