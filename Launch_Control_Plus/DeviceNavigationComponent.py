#Embedded file name: /Users/versonator/Jenkins/live/Binary/Core_Release_static/midi-remote-scripts/Launch_Control/DeviceNavigationComponent.py
import Live
from _Framework.ControlSurfaceComponent import ControlSurfaceComponent
from _Framework.SubjectSlot import subject_slot

from _Generic.Devices import parameter_bank_names, parameter_banks
import socket

class DeviceNavigationComponent(ControlSurfaceComponent):
    _next_button = None
    _previous_button = None

    def __init__(self, device_bank_reg):
        ControlSurfaceComponent.__init__(self)
        self._device_bank_reg = device_bank_reg
        self._on_device_bank_changed.subject = self._device_bank_reg
        self._selected_track = self.song().view.selected_track
        self._on_selected_device_changed.subject = self._selected_track.view

    def set_next_device_button(self, button):
        self._next_button = button
        self._update_button_states()
        self._on_next_device.subject = button

    def set_previous_device_button(self, button):
        self._previous_button = button
        self._update_button_states()
        self._on_previous_device.subject = button

    @subject_slot('value')
    def _on_next_device(self, value):
        if value:
            self._scroll_device_view(Live.Application.Application.View.NavDirection.right)

    @subject_slot('value')
    def _on_previous_device(self, value):
        if value:
            self._scroll_device_view(Live.Application.Application.View.NavDirection.left)

    def on_selected_track_changed(self):
        self._selected_track = self.song().view.selected_track
        self._on_selected_device_changed.subject = self._selected_track.view
        if self._selected_track.view.selected_device != None:
            bank = self._device_bank_reg.get_device_bank(self._selected_track.view.selected_device)
            self._send_bank_json(self._selected_track.view.selected_device, bank)
        else:
            self._send_clear_JSON()

    @subject_slot('selected_device')
    def _on_selected_device_changed(self):
        if self._selected_track.view.selected_device != None:
            bank = self._device_bank_reg.get_device_bank(self._selected_track.view.selected_device)            
            self._send_bank_json(self._selected_track.view.selected_device, bank)
        else:
            self._send_clear_JSON()

    @subject_slot('device_bank')
    def _on_device_bank_changed(self, device, bank):
        self._send_bank_json(device, bank)

    def _send_bank_json(self, device, bank):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(("127.0.0.1", 12000))

        bankJSON = ""
        banks = parameter_banks(device)
        if banks != None and bank < len(banks):
            paramNames = banks[bank]
            banksStr = parameter_bank_names(device)
            bankJSON = "{ \"name\":\"" + device.name + " > " + banksStr[bank] + "\", \"params\": ["
            for paramName in paramNames:
                if paramName != None:
                    bankJSON += "{ \"name\":\"" + paramName.name + "\" },"
                else:
                    bankJSON += "{ \"name\":\"------\" },"
            bankJSON += "]}"
        else:
            bankJSON = self._get_clear_JSON()

        s.send(bankJSON)
        s.close()

    def _get_clear_JSON(self):
        bankJSON = '{ "name":"------", "params": ['
        for i in range(0, 8):
            bankJSON += '{ "name":"------" },'
        bankJSON += "]}"
        return bankJSON

    def _send_clear_JSON(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(("127.0.0.1", 12000))
        s.send(self._get_clear_JSON())
        s.close()

    def _scroll_device_view(self, direction):
        self.application().view.show_view('Detail')
        self.application().view.show_view('Detail/DeviceChain')
        self.application().view.scroll_view(direction, 'Detail/DeviceChain', False)

    def _update_button_states(self):
        if self._next_button:
            self._next_button.turn_on()
        if self._previous_button:
            self._previous_button.turn_on()

    def update(self):
        super(DeviceNavigationComponent, self).update()
        if self.is_enabled():
            self._update_button_states()
            self._on_selected_device_changed()