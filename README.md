launchcontrolplus
=================

Simple tool for showing parameter names under control by Launch Control in Ableton Live. I created this as I quickly released that whilst the Launch Control is a great device it's very limiting not being able to see what parameters are under control. Currently Mac only but should be easy to write a Windows/cross platform client. This code is certainly not going to win any beauty contests but it pretty much works (**at least with Live 9.1.4, OSX 10.9.4**). Your mileage may vary.

**To use:**

- Place the Launch_Control_Plus directory in Live's MIDI Remote Scripts directory
- Open LaunchControlParameterShow in Xcode, build and run
- Start Live and select "Launch Control Plus" in prefs
- LaunchControlParameterShow should now show the parameter names for the currently selected bank and device

I do not claim any credit for the parts of this I didn't write. The socket handling code comes from an Apple example and of course the Launch Control scripts are modified versions of the original Live scripts. Use at your own risk, I will not be responsible for any problems you encounter, etc...

**Most of all, enjoy!**

*mcdreamer*
