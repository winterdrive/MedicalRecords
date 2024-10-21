// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MedicalRecords {
    struct MedicalRecord {
        string diagnosis;
        string treatment;
        uint256 date;
        address doctor;
    }

    // 每個病患的病歷 (mapping patient address => medical records array)
    mapping(address => MedicalRecord[]) private patientRecords;
    
    // 記錄醫療人員是否有權限查看或修改病患病歷
    mapping(address => mapping(address => bool)) public permissions; // patient => (doctor => hasPermission)

    // 新增病歷事件
    event MedicalRecordAdded(address indexed patient, string diagnosis, string treatment, uint256 date, address doctor);
    event PermissionGranted(address indexed patient, address indexed doctor, bool granted);

    // 添加新的病歷
    function addMedicalRecord(address _patient, string memory _diagnosis, string memory _treatment) public {
        require(permissions[_patient][msg.sender], "You do not have permission to add medical records for this patient.");
        MedicalRecord memory newRecord = MedicalRecord(_diagnosis, _treatment, block.timestamp, msg.sender);
        patientRecords[_patient].push(newRecord);

        emit MedicalRecordAdded(_patient, _diagnosis, _treatment, block.timestamp, msg.sender);
    }

    // 病患授權醫療人員查看或更新病歷
    function grantPermission(address _doctor, bool _granted) public {
        permissions[msg.sender][_doctor] = _granted;
        emit PermissionGranted(msg.sender, _doctor, _granted);
    }

    // 醫療人員查看病患的病歷
    function viewMedicalRecords(address _patient) public view returns (MedicalRecord[] memory) {
        require(permissions[_patient][msg.sender], "You do not have permission to view this patient's medical records.");
        return patientRecords[_patient];
    }
}
