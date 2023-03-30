import {
  Component,
  ElementRef,
  EventEmitter,
  Input,
  OnDestroy,
  OnInit,
  Output,
  ViewChild,
} from '@angular/core';
import { fade } from '../../utils/animations';
import { debounceTime, Subject, takeUntil } from 'rxjs';

@Component({
  selector: 'app-slider-setting',
  templateUrl: './slider-setting.component.html',
  styleUrls: ['./slider-setting.component.scss'],
  animations: [fade()],
})
export class SliderSettingComponent implements OnInit, OnDestroy {
  @Input() min = 0;
  @Input() max = 100;
  @Input() value = 50;
  @Input() step = 1;
  @Input() unit?: string;
  @Input() snapValues: number[] = [];
  @Input() snapDistance = 5;
  @Output() valueChange = new EventEmitter<number>();
  protected showOverlay = false;
  protected input$ = new Subject<string>();
  private destroy$ = new Subject<void>();

  @ViewChild('inputValue') inputEl?: ElementRef;

  ngOnInit(): void {
    this.input$.pipe(debounceTime(300), takeUntil(this.destroy$)).subscribe((strValue) => {
      let value = parseInt(strValue, 10);
      if (isNaN(value)) return;
      value = Math.max(this.min, Math.min(this.max, value));
      if (value === this.value) return;
      this.value = value;
      this.valueChange.emit(value);
    });
  }

  ngOnDestroy(): void {
    this.destroy$.next();
  }

  onInputBlur() {
    this.inputEl!.nativeElement.value = this.value.toString();
  }

  onSliderChange(value: number) {
    this.value = value;
    this.valueChange.emit(value);
  }
}