###
  * Copyright (c) 2011, iSENSE Project. All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
  *
  * Redistributions of source code must retain the above copyright notice, this
  * list of conditions and the following disclaimer. Redistributions in binary
  * form must reproduce the above copyright notice, this list of conditions and
  * the following disclaimer in the documentation and/or other materials
  * provided with the distribution. Neither the name of the University of
  * Massachusetts Lowell nor the names of its contributors may be used to
  * endorse or promote products derived from this software without specific
  * prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  * ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR
  * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
###
$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis", "embedVis", "show"]

    class window.Pie extends BaseHighVis
      constructor: (@canvas) ->
        if data.normalFields.length > 1
          @displayField = data.normalFields[1]
        else @displayField = data.normalFields[0]
          
        if !@select_name?
          
          if data.textFields.length > 2
            @select_name = data.textFields[2]
          else
            @select_name = 'Percent'

        @selected_field = @displayField
            
      start: () ->
        if data.textFields.length > 2 and namespace.action is 'displayVis'
          data.setGroupIndex(data.textFields[2])
          globals.groupSelection = for vals, keys in data.groups
            Number keys
        super()
        @update()
        console.log globals.fieldSelection
      update: () ->
        @rel_data = []
        @selected_field = @displayField
        @getGroupedData()
        while @chart.series.length > 0
          @chart.series[@chart.series.length - 1].remove false

        @select_name = data.fields[data.groupingFieldIndex].fieldName
#         fieldSortedGroupIDs = for groupName, groupID in data.groups
#           groupID
#         for groupIndex, order in fieldSortedGroupIDs when groupIndex in globals.groupSelection
        console.log @display_data
        options =
          showInLegend: false
          data: @display_data
            
          
        @chart.setTitle { text: "#{@select_name} by #{data.fields[@selected_field].fieldName}" }

        @chart.addSeries options, false
        #@chart.series = globals.colors
        @chart.redraw()

      normalize: ->
        sum = @display_data.reduce (prev, cur) -> prev + cur
        
        @display_data = @display_data.map (prev, cur) ->
          cur[1] = (cur[1] / sum) * 100
          cur
        , []

      getGroupedData: ->
        #options.data = for fieldIndex in data.normalFields when fieldIndex in globals.fieldSelection
        @display_data = 
        [
	  ["a",0],
	  ["b",0],
	  ["c",0]
	]  
#         @display_data = data.dataPoints.reduce (prev, next) =>
#           #console.log prev
#           #console.log next
#           if prev[data.groupingFieldIndex]?
#             #console.log '#truuuu'
#             prev[next[data.groupingFieldIndex]] += next[@selected_field]
#           else
#             #console.log '#false'
#             prev[next[data.groupingFieldIndex]] = next[@selected_field]
#           prev
#         , {}
# 
#         @display_data = Object.keys(@display_data).reduce (prev, key) =>
#           prev.push [key, @display_data[key]]
#           prev
#           
#         , []
        
      buildOptions: ->
        super()

        self = this
        @chartOptions

        $.extend true, @chartOptions,
          chart:
            type: "pie"
          title:
            text: "#{data.fields[@selected_field].fieldName}"
          tooltip:
            pointFormat: '{point.name}: <b>{point.percentage:.1f}%</b>'
          plotOptions:
            pie:
              allowPointSelect: true
              cursor: 'pointer'
              dataLabels:
                enabled: true
                format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                style:
                  color: 'black'
          series: [{
            type: 'pie'
            data:
              [['Firefox', 50], ['Other', 50]]
            }]

      drawLabelControls: ->
        controls = '<div id="labelControl" class="vis_controls">'
        controls += "<h3 class='clean_shrink'><a href='#'>Label:</a></h3>"
        controls += "<div class='outer_control_div'>"
        for fields, f_index in data.fields
          do ->
            controls += "<div class='inner_control_div'><div class='radio'><label>#{data.fields[fields].fieldName}"
            controls += "<input class='label_input' type='radio' name='labels' value='#{fields}'"
            if f_index == 0
              controls += "checked"
            controls += "></label></div></div>"

        controls += '</div></div>'
        ($ '#controldiv').append controls
        
        ($ '.label_input').click (e) =>
          @select_name = Number e.target.value
          @delayedUpdate()
        
        globals.labelOpen ?= 0
        ($ '#labelControl').accordion
          collapsible: true
          active: globals.labelOpen
          
        ($ '#labelControl > h3').click ->
          globals.labelOpen = (globals.labelOpen + 1) % 2

      drawControls: ->
        super()
        @drawGroupControls false, false, false
        @drawYAxisControls true, false #horrible name for what im doing here
        #@drawLabelControls()
        @drawSaveControls()


    if "Pie" in data.relVis
      globals.pie = new Pie 'pie_canvas'
      #globals.percentage = new Bar 'percentage_canvas'
    else
      globals.pie = new DisabledVis 'pie_canvas'