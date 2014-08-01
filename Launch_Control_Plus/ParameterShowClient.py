#Embedded file name: /Users/versonator/Jenkins/live/Binary/Core_Release_static/midi-remote-scripts/Launch_Control/LaunchControl.py
from _Framework.DeviceBankRegistry import DeviceBankRegistry
from _Framework.SubjectSlot import subject_slot
from _Generic.Devices import parameter_bank_names, parameter_banks

class ParameterShowClient:

    def __init__(self):
        f = open('/Users/andrew/bank.json', 'w')
        f.write("hi")
        f.close()

    def setup(self, device_bank_registry):
        self._on_device_bank_changed.subject = device_bank_registry

    @subject_slot('device_bank')
    def _on_device_bank_changed(self, device, bank):
        banks = parameter_banks(device)
        bankNames = banks[bank]
        banksStr = parameter_bank_names(device)
        str = banksStr[bank]
        for bankName in bankNames:
            str += ", " + bankName.name
        f = open('/Users/andrew/bank.json', 'w')
        f.write(str)
        f.close()
