
  --DateTime dt = new DateTime(2001, 7, 13, 4, 0, 0);



(
f = dotnetObject "form" 
tp = dotnetObject "DateTimePicker"
tp.AccessibleRole = tp.AccessibleRole.clock
tp.Anchor = tp.Anchor.none
tp.ShowCheckBox = 	false
tp.ShowUpDown = 	false
tp.Dock = tp.Dock.none
tp.format =tp.format.Time--Custom--long--Short--
--tp.value = tp.value.Today
--print tp.value.Today
f.controls.add tp
f.show(WindowWrapper)
)

tf = dotnetClass "DateTimePickerFormat" 
tf.short
t = dotNetClass "System.DateTime"
t.Now.hour
t.Now.Ticks
t.Now
t.Now.Minute
t.Now.Hour
t.Now.Month
t.Now.Year
t.Now.Date
t.Now.Day
t.Now.TimeOfDay
t.Now.GetDateTimeFormats()
t.Now.ToString()
t.Now.ToShortTimeString()
t.Now.ToShortDateString()
t.Now.ToString "MM/dd/yyyy hh:mm:sszzz"
t.Now.ToString "HH:mm dddd dd MMMM"
t.Now.ToString "HH:mm ddd dd MMMM"
t.Now.ToString "hh:mm MM/dd/yyyy"

mcsystem.show t.now

gc()

