package com.example.bangkok_weather

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Implementation of App Widget functionality.
 */
class WeatherWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.weather_widget).apply {

                val temp = widgetData.getString("weather_temp", null)
                setTextViewText(R.id.weather_temp, temp ?: "Temp")

                val description = widgetData.getString("weather_description", null)
                setTextViewText(R.id.weather_description, description ?: "Description")
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}